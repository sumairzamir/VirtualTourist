//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 10/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<Pin>!

    func setupFetchedResultsController() {

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            print("fetch works")
            print(fetchedResultsController.fetchedObjects?.count)
        } catch {

            fatalError(error.localizedDescription)

        }


    }
    
    
    @IBAction func testButton(_ sender: Any) {
        
        NetworkGetRequests.requestNumberOfPages(lat: 51, long: 0, completionHandler: handleTestButtonResponse(success:response:error:))
        
    }
    
    func handleTestButtonResponse(success: Bool, response: Int?, error: Error?) {
        
        if success {
            NetworkParameters.Endpoints.ceilingPageNumber = UInt32(response!)
            print(response)
            print(NetworkParameters.Endpoints.randomPage)
        } else {
            print(error)
        }
    }
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
        // FETCHED objects into annotations...sorted
        
        // Think about how to delete pins...add pins in the core data stack..? with the delegate extension
        
        travelLocationsMapView.addAnnotations(fetchedResultsController.fetchedObjects!)
        
        
        
        
        
        
        

        
        
        
        
        // ZOOM & Center
        
        let location = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"), longitude: UserDefaults.standard.double(forKey: "Longitude"))
        
        let latitudeZoom = UserDefaults.standard.double(forKey: "LatitudeZoom")
        let longitudeZoom = UserDefaults.standard.double(forKey: "LongitudeZoom")
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeZoom, longitudeDelta: longitudeZoom)
        
        let zoom = MKCoordinateRegion(center: location, span: span)
        travelLocationsMapView.setRegion(zoom, animated: true)
        

        let longTapRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        
        longTapRecogniser.minimumPressDuration = 1
        
        travelLocationsMapView.addGestureRecognizer(longTapRecogniser)
        
        let annotation = MKPointAnnotation()
        
        travelLocationsMapView.addAnnotation(annotation)
        
        // Deselects all pins!
        
        travelLocationsMapView.selectedAnnotations.forEach({travelLocationsMapView.deselectAnnotation($0, animated: false)})
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupFetchedResultsController()
        
        self.travelLocationsMapView.delegate = self
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(travelLocationsMapView.centerCoordinate.latitude, forKey: "Latitude")
        UserDefaults.standard.set(travelLocationsMapView.centerCoordinate.longitude, forKey: "Longitude")
        UserDefaults.standard.set(travelLocationsMapView.region.span.latitudeDelta, forKey: "LatitudeZoom")
        UserDefaults.standard.set(travelLocationsMapView.region.span.longitudeDelta, forKey: "LongitudeZoom")
     
    }
    
    
    
    
    @objc func handleLongTap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        let location = sender.location(in: travelLocationsMapView)
        
        let coordinates = travelLocationsMapView.convert(location, toCoordinateFrom: travelLocationsMapView)
        
        let tapPin = MKPointAnnotation()
        
        tapPin.coordinate = coordinates
        
        tapPin.title = "testing"
        
        tapPin.subtitle = "testing"
        
        
        let savePin = Pin(context: dataController.viewContext)
        
        savePin.latitude = coordinates.latitude
        savePin.longitude = coordinates.longitude
        
        try? dataController.viewContext.save()
        
        
        travelLocationsMapView.addAnnotation(tapPin)
        
        
//        let markerView = sender.view as! MKMarkerAnnotationView
//
//         performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: markerView)
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "reuseId"
        
        var markerView = travelLocationsMapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        markerView?.animatesWhenAdded = true
        
        markerView?.glyphTintColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pinTapped(_:)))
        
        markerView!.addGestureRecognizer(tapGesture)
        
        return markerView
        
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
////
////        let marker = view.annotation
////
////        travelLocationsMapView.selectAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>, animated: <#T##Bool#>)
////
////        travelLocationsMapView.deselectAnnotation(marker, animated: false)
//
////        view.annotation.self = fetchedResultsController.obj
//
////
//
//
//
//         performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: self)
//
//    }
    
    @objc func pinTapped(_ gesture: UITapGestureRecognizer) {
        
        let pinView = gesture.view as! MKMarkerAnnotationView
        
        performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: pinView)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let navController = segue.destination as? UINavigationController {

            let nextVC = navController.topViewController as! PhotoAlbumViewController
            
            let coordinate = (sender as? MKMarkerAnnotationView)?.annotation!.coordinate

            let pinArray = fetchedResultsController.fetchedObjects!
            
            // Check for annotation within the array of all annotations
            
            guard let index = pinArray.firstIndex(where: { (pin) -> Bool in
                
                pin.latitude == coordinate?.latitude && pin.longitude == coordinate?.longitude })
                else { return }
            
            let selectedPin = pinArray[index]
            
            nextVC.pin = selectedPin

            print(nextVC.pin)

            nextVC.dataController = dataController
            
        } else {

        fatalError("did not pass through")
            
        }

    }
    
    
}
//
//extension TravelLocationsMapViewController {
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        guard let point = anObject as? Pin else {
//            preconditionFailure("All changes observed in the map view controller should be for Point instances")
//        }
//
//        switch type {
//        case .insert:
//            travelLocationsMapView.addAnnotation(point)
//
//        case .delete:
//            travelLocationsMapView.removeAnnotation(point)
//
//        case .update:
//            travelLocationsMapView.removeAnnotation(point)
//            travelLocationsMapView.addAnnotation(point)
//
//        case .move:
//            // N.B. The fetched results controller was set up with a single sort descriptor that produced a consistent ordering for its fetched Point instances.
//            fatalError("How did we move a Point? We have a stable sort.")
//        @unknown default:
//            fatalError()
//        }
//    }
//
    
    



