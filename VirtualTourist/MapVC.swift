//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Frédéric Lépy on 27/06/2015.
//  Copyright (c) 2015 Frédéric Lépy. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: Lyfecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Persit map region
        restoreMapRegion(false)
        
        //Add gesture recognizer to the map view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressGesture.minimumPressDuration = 0.8
        mapView.addGestureRecognizer(longPressGesture)
        
        //Get the saved pins
        fetchedResultsController.performFetch(nil)
        
        let sectionInfo = self.fetchedResultsController.sections?.first as! NSFetchedResultsSectionInfo
        println("There are \(sectionInfo.numberOfObjects) objects saved")
        
        //Display the saved pins
        displaySavedPins()
    }
    
    override func viewDidDisappear(animated: Bool) {
        println("view did disappear")
    }
    
    
    //MARK: Fetched Results

    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStackManager.sharedInstance().managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    

    //MARK: Map Persistance helper methods
    
    var filePath : String {
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func saveMapRegion() {
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func restoreMapRegion(animated: Bool) {
  
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    func displaySavedPins() {
        
        if let s = fetchedResultsController.sections?.first?.objects as? [VTAnnotation] {
            
            var annotations = [VTAnnotation]()
            
            for pin in s {
                
                annotations.append(pin)
            }
            
            mapView.addAnnotations(annotations)
        }
    }
    
    
    //MARK: Map Delegate
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let view = self.mapView.dequeueReusableAnnotationViewWithIdentifier("pin") {
            return view
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView.enabled = true
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
            pinView.draggable = true
            return pinView
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        //When pin is tapped, segue to Collection View Controller
        let pin = view.annotation as! VTAnnotation
        performSegueWithIdentifier("CollectionVCSegue", sender: pin)
    }
    
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        //Pass the pin as argument for the Collection View Controller
        if segue.identifier == "CollectionVCSegue" {

            //TODO:
            let collectionVC = segue.destinationViewController as! CollectionViewController
            collectionVC.pin = sender as! VTAnnotation
        }
    }
    
    
    //MARK: Touches
    
    func handleLongPress (gestureRecognizer: UIGestureRecognizer) -> Void {
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
        
            //Get the point where the map was touched
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
            //Create the dictionary to create the pin
            let dictionary: [String : AnyObject] = [
                "latitude" : touchMapCoordinate.latitude,
                "longitude" : touchMapCoordinate.longitude,
                "title" : "Test",
                "subtitle" : "test",
            ]
        
            //Create the pin with the dictionary
            let pin = VTAnnotation(dictionary: dictionary, context: CoreDataStackManager.sharedInstance().managedObjectContext!)
        
            //Add the pin to the map
            mapView.addAnnotation(pin)
            
            //Pre-load  12 photos in the pin's photos array in the background
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue, {
                
                if pin.photos.isEmpty {
                    println("will pre-load photos")
                    NetworkingHelperClass.getPhotosByLatLonForPin(pin, lat: touchMapCoordinate.latitude, lon: touchMapCoordinate.longitude)
                }
            })
            
            //Save the context when the pin is at its final location
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    
    //MARK: Networking
    
}

