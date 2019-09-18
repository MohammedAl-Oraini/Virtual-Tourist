//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 11/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    //MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Core Data Persistent Container
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    //MARK: - helper var
    
    var lat:Double {
        return mapView.centerCoordinate.latitude
    }
    var long:Double {
        return mapView.centerCoordinate.longitude
    }
    var span:MKCoordinateSpan {
        return mapView.region.span
    }
    
    var editState:Bool = false
    var navigationBarTintColor:UIColor?
    
    //MARK: - app life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
        navigationBarTintColor = navigationController?.navigationBar.barTintColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore"){
            setupMapView()
            loadPins()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    //MARK: - set up methods
    
    fileprivate func setupMapView() {
        let locationCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "lat"), longitude: UserDefaults.standard.double(forKey: "long"))
        let coordinateSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: UserDefaults.standard.double(forKey: "latDelta"), longitudeDelta: UserDefaults.standard.double(forKey: "longDelta"))
        let region:MKCoordinateRegion = MKCoordinateRegion(center: locationCoordinate , span: coordinateSpan)
        mapView.setRegion(region, animated: true)
    }
    
    func loadPins() {
        for pin in Pin.loadPins(container: container) {
            let newPin = MKPointAnnotation()
            newPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(newPin)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool){
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.title = "Tap Pins To Delete"
            navigationController?.navigationBar.barTintColor = .red
            navigationController?.navigationBar.tintColor = .white
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
            editState = true
        }else {
            navigationItem.title = "Virtual Tourist"
            navigationController?.navigationBar.barTintColor = navigationBarTintColor
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1)
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
            editState = false
        }
    }

    
    //MARK: - IBActions
    
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        if editState {
            return
        } else {
            switch sender.state {
            case .began:
                print("began long gesture")
                let touchedAt = sender.location(in: self.mapView)
                let touchAtCoordinate:CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
                
                let newPin = MKPointAnnotation()
                newPin.coordinate = touchAtCoordinate
                mapView.addAnnotation(newPin)
                Pin.savePin(latitude: touchAtCoordinate.latitude, longitude: touchAtCoordinate.longitude, container: container)
            case.ended:
                print("ended long gesture")
            default:
                print("some thing happened")
            }
        }
    }
    
    //MARK: - prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? PhotoAlbumCollectionViewController {
            vc.container = container
        }
    }
    
}

//MARK: - Map View Delegate extension

extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserDefaults.standard.set(long, forKey: "long")
        UserDefaults.standard.set(lat, forKey: "lat")
        UserDefaults.standard.set(span.latitudeDelta, forKey: "latDelta")
        UserDefaults.standard.set(span.longitudeDelta, forKey: "longDelta")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editState {
            if let pin = view.annotation {
                mapView.removeAnnotation(pin)
                Pin.deletePin(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, container: container)
            }
        } else {
        PhotoAlbumCollectionViewController.lat = (view.annotation?.coordinate.latitude)!
        PhotoAlbumCollectionViewController.long = (view.annotation?.coordinate.longitude)!
        performSegue(withIdentifier: "pinPhotos", sender: view)
        }
    }
}
