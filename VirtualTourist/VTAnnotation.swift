//
//  VTAnnotation.swift
//  VirtualTourist
//
//  Created by Frédéric Lépy on 27/06/2015.
//  Copyright (c) 2015 Frédéric Lépy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@objc(VTAnnotation)

class VTAnnotation: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude : CLLocationDegrees
    @NSManaged var longitude : CLLocationDegrees
    @NSManaged var title : String
    @NSManaged var subtitle : String
    @NSManaged var photos : [Photo]
    
    var coordinate : CLLocationCoordinate2D {
        get {
            let coord = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            return coord
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        //Get the information from the model file
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        //Insert our new object in the context
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //Init the properties of our pin
        let lat = dictionary["latitude"] as! CLLocationDegrees
        latitude = lat
        let long = dictionary["longitude"] as! CLLocationDegrees
        longitude = long
        title = dictionary["title"] as! String
        subtitle = dictionary["subtitle"] as! String
    }
}
