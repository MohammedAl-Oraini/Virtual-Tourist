//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 13/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    //MARK: - helper methods

    class func loadPhotos(pin: Pin,container: NSPersistentContainer?) -> [Photo]{
        if let container = container {
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "location == %@", pin)
            request.predicate = predicate
            do {
                let photos = try container.viewContext.fetch(request)
                print("photos loaded with :\(photos.count) photos")
                return photos
            } catch {
                print("error loading the photos")
            }
        }
        print("returned with an emity arry")
        return []
    }
    
    class func savePhoto(pin:Pin,data:Data,container: NSPersistentContainer?){
        //DispatchQueue.main.async {
            if let container = container {
                print("is main thread ? \(Thread.isMainThread)")
                let newPhoto = Photo(context: container.viewContext)
                newPhoto.imageData = data
                newPhoto.location = pin
                try? container.viewContext.save()
                print("new photo saved")
            } else {
                print("photo was not saved")
            }
    }
    
    class func deletePhoto(indexPath:Int,pin:Pin,container: NSPersistentContainer?) {
        if let container = container {
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "location == %@", pin)
            request.predicate = predicate
            do {
                let photos = try container.viewContext.fetch(request)
                print("photos loaded with :\(photos.count) photos and ready to delete a photo")
                let photoToBeDeleted = photos[indexPath]
                container.viewContext.delete(photoToBeDeleted)
                try? container.viewContext.save()
                
            }
            catch {
                print("error loading the photos")
            }
            
        }
    }
    
    class func deletePhotos(pin:Pin,container: NSPersistentContainer?) {
        if let container = container {
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "location == %@", pin)
            request.predicate = predicate
            do {
                let photos = try container.viewContext.fetch(request)
                print("photos loaded with :\(photos.count) photos and ready to delete a photo")
                for photo in photos {
                container.viewContext.delete(photo)
                try? container.viewContext.save()
                }
            }
            catch {
                print("error loading the photos")
            }
            
        }
    }
}
