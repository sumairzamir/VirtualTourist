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

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var travelLocationsMapView: MKMapView!
    // Definition of the DataController and the FRC in the ViewController.
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // On return to the view, deselect all the PointAnnotations.
        travelLocationsMapView.selectedAnnotations.forEach({travelLocationsMapView.deselectAnnotation($0, animated: false)})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        travelLocationsMapView.delegate = self
        // Add all the annotations from the FRC.
        travelLocationsMapView.addAnnotations(fetchedResultsController.fetchedObjects!)
        // Center the MapView based on where the user left the MapView on previous app close using UserDefaults.
        let location = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"), longitude: UserDefaults.standard.double(forKey: "Longitude"))
        let latitudeZoom = UserDefaults.standard.double(forKey: "LatitudeZoom")
        let longitudeZoom = UserDefaults.standard.double(forKey: "LongitudeZoom")
        let span = MKCoordinateSpan(latitudeDelta: latitudeZoom, longitudeDelta: longitudeZoom)
        let zoom = MKCoordinateRegion(center: location, span: span)
        travelLocationsMapView.setRegion(zoom, animated: true)
        // Define the LongPress recogniser and instantiate a new PointAnnotation on the MapView.
        let longTapRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        longTapRecogniser.minimumPressDuration = 1
        travelLocationsMapView.addGestureRecognizer(longTapRecogniser)
        
        let annotation = MKPointAnnotation()
        travelLocationsMapView.addAnnotation(annotation)
    }
    // As the user adjusts the MapView the parameters are saved to the UserDefaults.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(travelLocationsMapView.centerCoordinate.latitude, forKey: "Latitude")
        UserDefaults.standard.set(travelLocationsMapView.centerCoordinate.longitude, forKey: "Longitude")
        UserDefaults.standard.set(travelLocationsMapView.region.span.latitudeDelta, forKey: "LatitudeZoom")
        UserDefaults.standard.set(travelLocationsMapView.region.span.longitudeDelta, forKey: "LongitudeZoom")
    }
    // Method to handle the LongPress.
    @objc func handleLongTap(_ sender: UILongPressGestureRecognizer) {
        // If the sender, i.e. LongPress has not began (BOOL) the method is not called and returns.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        // Determine the location pressed on the MapView.
        let location = sender.location(in: travelLocationsMapView)
        // Convert the location to coordinates.
        let coordinates = travelLocationsMapView.convert(location, toCoordinateFrom: travelLocationsMapView)
        // Instantiate a PointAnnotation and set its coordinates as above.
        let tapPin = MKPointAnnotation()
        tapPin.coordinate = coordinates
        travelLocationsMapView.addAnnotation(tapPin)
        // Save the pin into the Pin entity.
        let savePin = Pin(context: dataController.viewContext)
        savePin.latitude = coordinates.latitude
        savePin.longitude = coordinates.longitude
        try? dataController.viewContext.save()
        // Perform a fetch so that the controller is updated. This is equivalent to the FetchedResultsControllerDelegate.
        // try? fetchedResultsController.performFetch()
    }
    // Method similar to those in TableViews & CollectionViews.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "reuseId"
        var markerView = travelLocationsMapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        markerView?.animatesWhenAdded = true
        markerView?.glyphTintColor = .black
        // Define a tap gesture, so that a sender is defined when the pin is called/tapped.
        // This is required so that the details of the specific pin can called in the PhotoAlbumViewController.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pinTapped(_:)))
        markerView!.addGestureRecognizer(tapGesture)
        
        return markerView
    }
    // On tapping the pin perform the segue to the PhotoAlbumViewController.
    @objc func pinTapped(_ gesture: UITapGestureRecognizer) {
        let pinView = gesture.view as! MKMarkerAnnotationView
        performSegue(withIdentifier: "PhotoAlbumViewSegue", sender: pinView)
    }
    // As the segue is called, parameters are passed through to the PhotoAlbumViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass through to the PhotoAlbumViewController after passing through the NavigationController.
        if let navController = segue.destination as? UINavigationController {
            let nextVC = navController.topViewController as! PhotoAlbumViewController
            // Get the coordinates from the sender, i.e. the MarkerAnnotation pressed by the user.
            let coordinate = (sender as? MKMarkerAnnotationView)?.annotation!.coordinate
            // Define an array of pins based on the objects within the FRC.
            let pinArray = fetchedResultsController.fetchedObjects!
            // Check for annotation within the array of all annotations, based on a Bool condition where the coordinates match.
            guard let index = pinArray.firstIndex(where: { (pin) -> Bool in
                pin.latitude == coordinate?.latitude && pin.longitude == coordinate?.longitude })
                else { return }
            // Within the PinArray select the Pin entity where the condition above for index is met.
            let selectedPin = pinArray[index]
            // Set pin variable in PhotoAlbumViewController as the selected pin and pass the DataController through.
            nextVC.pin = selectedPin
            nextVC.dataController = dataController
        } else {
            fatalError("Unable to save parameters.")
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    // Given the basic function of the MapView this could be replaced by a perform fetch call once the annotation is added. Used for practice purposes.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //Defining pin as a Pin entity.
        guard let pin = anObject as? Pin else {
            return
        }
        switch type {
        case .insert: travelLocationsMapView.addAnnotation(pin)
            break
        default:
            break
        }
    }
    
}


