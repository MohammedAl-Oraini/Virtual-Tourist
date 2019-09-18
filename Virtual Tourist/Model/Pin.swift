//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Mohammad Al-Oraini on 13/09/2019.
//  Copyright © 2019 Mohammad Al-Oraini. All rights reserved.
//

import UIKit
import CoreData

class Pin: NSManagedObject {
    
    //MARK: - helper methods
    
    
    class func savePin(latitude:Double,longitude:Double,container: NSPersistentContainer?){
        if let container = container {
            print("is main thread ? \(Thread.isMainThread)")
            let newPin = Pin(context: container.viewContext)
            newPin.latitude = latitude
            newPin.longitude = longitude
            try? container.viewContext.save()
            print("new pin saved")
        } else {
            print("pin was not saved")
        }
        
    }

    class func loadPins(container: NSPersistentContainer?) -> [Pin]{
        if let container = container {
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            do {
                let pins = try container.viewContext.fetch(request)
                print("pins loaded with :\(pins.count) pins")
                return pins
            } catch {
               print("error loading the pins")
            }
        }
        print("returned with an emity arry")
        return []
    }
    
    class func deletePin(latitude:Double,longitude:Double,container: NSPersistentContainer?) {
        if let container = container {
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            do {
                let pins = try container.viewContext.fetch(request)
                print("pins loaded and ready to loop throw \(pins.count) pins")
                for pin in pins {
                    if pin.latitude == latitude && pin.longitude == longitude {
                        print("Found a mtch")
                        container.viewContext.delete(pin)
                        try? container.viewContext.save()
                    }
                }
            } catch {
                print("error loading the pins")
            }
            
        }
    }
    
    class func getPin(latitude:Double,longitude:Double,container: NSPersistentContainer?) -> Pin? {
        if let container = container {
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            do {
                let pins = try container.viewContext.fetch(request)
                print("pins are ready to loop throw \(pins.count) pins and find your pin")
                for pin in pins {
                    if pin.latitude == latitude && pin.longitude == longitude {
                        print("Found your pin")
                        return pin
                    }
                }
                print("creating a new pin")
                let newPin = Pin(context: container.viewContext)
                newPin.latitude = latitude
                newPin.longitude = longitude
                try? container.viewContext.save()
                return newPin
            } catch {
                print("error loading the pins")
            }
            
        }
        print("returning nil")
        return nil
    }
    
}
