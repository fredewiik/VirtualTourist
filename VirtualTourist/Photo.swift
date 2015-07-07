//
//  Photo.swift
//  VirtualTourist
//
//  Created by Frédéric Lépy on 04/07/2015.
//  Copyright (c) 2015 Frédéric Lépy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    @NSManaged var pin: VTAnnotation?
    @NSManaged var urlPath: String?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        println("will create photo object")
        
        //Get the information from the model file
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        //Insert our new object in the context
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //Init the properties of our pin
        urlPath = dictionary["urlPath"] as? String
    }
    
    var posterImage: UIImage? {
        
        get {
            return AppDelegate.Caches.imageCache.imageWithIdentifier(urlPath)
        }
        
        set {
            AppDelegate.Caches.imageCache.storeImage(newValue, withIdentifier: urlPath!)
        }
    }
}
