//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 12/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "Cell"

class PhotoAlbumCollectionViewController: UIViewController {
    
    //MARK: - Core Data Persistent Container
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    var pin: Pin!

    //MARK: - IBOutlet
    
    @IBOutlet weak var pinMap: MKMapView!
    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet weak var noImagesLabel: UILabel!

    //MARK: - injection var
    
    static var long: Double = 0.0
    static var lat: Double = 0.0
    
    //MARK: - helper var
    
    var pages = 1
    var numberOfSelectedPhoto = 0 {
        didSet {
            if editState {
                newCollectionBarButton.title = "Remove Selected Pictures"
            } else {
                newCollectionBarButton.title = "New Collection"
            }
        }
    }
    var editState:Bool {
        if numberOfSelectedPhoto == 0 {
            return false
        } else {
            return true
        }
    }
    
    //MARK: - data source var
    
    var imageCollection:[UIImage] = []
    
    //MARK: - app life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlowLayout()
        photosCollection.delegate = self
        photosCollection.dataSource = self
        photosCollection.allowsMultipleSelection = true
        newCollectionBarButton.isEnabled = false
        
        // set up Pin to be used in relation with Photo
        
        pin = Pin.getPin(latitude: PhotoAlbumCollectionViewController.lat, longitude: PhotoAlbumCollectionViewController.long, container: container)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupPinMap()
        setupPhotoCollection()
        noImagesLabel.isHidden = true
        if imageCollection.isEmpty{
            newCollectionBarButton.isEnabled = false
            VirtualTouristClient.getPhotosInfo(longitude: PhotoAlbumCollectionViewController.long, latitude: PhotoAlbumCollectionViewController.lat, page: 1, completion: handlePhotosInfo(flickerPhotos:pages:error:))
        }
    }
    
    //MARK: - set up methods
    
    func setupFlowLayout() {
        
        let numberOfItemPerRow:CGFloat = 2
        let space:CGFloat = 10.0
        let width = (photosCollection.frame.width - (numberOfItemPerRow - 1) * space) / numberOfItemPerRow
        let height = width
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setupPinMap(){
        let location = CLLocationCoordinate2D(latitude: PhotoAlbumCollectionViewController.lat, longitude: PhotoAlbumCollectionViewController.long)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pinMap.addAnnotation(pin)
        
        pinMap.isZoomEnabled = false
        pinMap.isScrollEnabled = false
        pinMap.isPitchEnabled = false
        pinMap.isRotateEnabled = false
        pinMap.setRegion(region, animated: false)
    }
    
    func setupPhotoCollection(){
        let photoCollection = Photo.loadPhotos(pin: pin, container: container)
        if photoCollection.isEmpty {
            print("No photos here")
            newCollectionBarButton.isEnabled = true
            return
        }
        for photo in photoCollection {
            let imageData = photo.imageData
            let image = UIImage(data: imageData!)!
            imageCollection.append(image)
        }
        photosCollection.reloadData()
        newCollectionBarButton.isEnabled = true
    }
    
    //MARK: - IBActions
    
    @IBAction func newCollectionTapped(_ sender: UIBarButtonItem) {
        if editState {
            if let indexPaths = photosCollection.indexPathsForSelectedItems {
                let sortedIndexPaths = indexPaths.sorted(by: >)
                for indexPath in sortedIndexPaths {
                    imageCollection.remove(at: indexPath.row)
                    Photo.deletePhoto(indexPath: indexPath.row, pin: pin, container: container)
                }
                numberOfSelectedPhoto = 0
                photosCollection.reloadData()
            }
        } else if editButtonItem.isEnabled && imageCollection.isEmpty{
            newCollectionBarButton.isEnabled = false
            noImagesLabel.isHidden = true
            VirtualTouristClient.getPhotosInfo(longitude: PhotoAlbumCollectionViewController.long, latitude: PhotoAlbumCollectionViewController.lat, page: 1, completion: handlePhotosInfo(flickerPhotos:pages:error:))
        } else {
            newCollectionBarButton.isEnabled = false
            numberOfSelectedPhoto = 0
            imageCollection.removeAll()
            Photo.deletePhotos(pin: pin, container: container)
            photosCollection.reloadData()
            print("new collection")
            let page = Int.random(in: 1...pages)
            VirtualTouristClient.getPhotosInfo(longitude: PhotoAlbumCollectionViewController.long, latitude: PhotoAlbumCollectionViewController.lat, page: page, completion: handlePhotosInfo(flickerPhotos:pages:error:))
        }
    }
    
    //MARK: - handle methods
    
    func handlePhotosInfo(flickerPhotos:[FlickerPhoto],pages:Int?,error:Error?){
        
        if let pages = pages {
            self.pages = pages
        }
        
        if flickerPhotos.count == 0 {
            print("no photos here")
            DispatchQueue.main.async {
                self.noImagesLabel.isHidden = false
                self.newCollectionBarButton.isEnabled = true
            }
        }else {
            
            var imageNumber = 0
            for photo in flickerPhotos {
                
                // set up the images placeholder
                
                DispatchQueue.main.async {
                    let image = UIImage(named: "placeholderImageSquare")
                    self.imageCollection.append(image!)
                    self.photosCollection.reloadData()
                }
                
                // getting the image data
                
                let url = URL(string: photo.imageUrl)!
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "error in dataTask")
                        return
                    }
                    guard let data = data else {
                        print("data erroe")
                        return
                    }
                    
                    // loading and saving the images
                    
                    DispatchQueue.main.async {
                        _ = Photo.savePhoto(pin: self.pin, data: data, container: self.container)
                        let image = UIImage(data: data)
                        self.imageCollection[imageNumber] = image!
                        self.photosCollection.reloadData()
                        imageNumber += 1
                        if imageNumber == (flickerPhotos.count) {
                            self.newCollectionBarButton.isEnabled = true
                            imageNumber = 0
                        }
                    }
                }
                task.resume()
            }
        }
    }
}

//MARK: - UICollectionView Delegate and DataSource extension

extension PhotoAlbumCollectionViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = imageCollection[indexPath.row]
        cell.layer.cornerRadius = 15
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select \(indexPath.row)")
        numberOfSelectedPhoto += 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect \(indexPath.row)")
        numberOfSelectedPhoto -= 1
    }
    
}
