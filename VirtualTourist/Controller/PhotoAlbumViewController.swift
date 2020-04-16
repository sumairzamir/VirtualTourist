//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 10/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    @IBOutlet weak var collectionMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
              fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
        NetworkGetRequests.requestNumberOfPages(lat: pin.latitude, long: pin.longitude, completionHandler: handleNumberOfPages(success:response:error:))
        
        NetworkGetRequests.requestPhotoSearchByLatLon(lat: pin.latitude, long: pin.longitude, completionHandler: handleGetRequest(success:response:error:))
//        print(Test.test.count)
        
    }
    
    func handleNumberOfPages(success: Bool, response: Int?, error: Error?) {
        
        if success {
            NetworkParameters.Endpoints.ceilingPageNumber = UInt32(response!)
            NetworkParameters.Endpoints.randomPage = arc4random_uniform(NetworkParameters.Endpoints.ceilingPageNumber)
            
            print(NetworkParameters.Endpoints.randomPage)
            print(NetworkParameters.Endpoints.ceilingPageNumber)
            
            print(arc4random_uniform(NetworkParameters.Endpoints.ceilingPageNumber))
            
            print(response)
            
        }
        
        else {
            
            print (error)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupFetchedResultsController()
        
        
        let coordinates = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        
        
        let fixedSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let setRegion = MKCoordinateRegion(center: coordinates, span: fixedSpan)
        
        collectionMapView.setRegion(setRegion, animated: false)
        collectionMapView.addAnnotation(pin)
        collectionMapView.isUserInteractionEnabled = false
        
        print(collectionView.isUserInteractionEnabled)
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    @IBAction func dismissPhotoAlbumView(_ sender: Any) {
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //    @IBAction func getRequestTest(_ sender: Any) {
    //
    //
    //
    //    }
    
    func handleGetRequest(success: Bool, response: [PhotosArray]?, error: Error?) {
        
        if success {
            
            if fetchedResultsController.fetchedObjects!.count == 0 {
            
            for photos in response! {
                
                let photo = Photos(context: dataController.viewContext)
                photo.photo = photos.individualPhotos?.pngData()
                photo.pin = pin
                try? dataController.viewContext.save()
                
            }
            //
            //                Test.test = response!
            //                print(success)
            //                print(Test.test.count)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
                } }
            
        } else {
            
            print(error)
        }
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //            return Test.test.count
        print(fetchedResultsController.sections?[section].numberOfObjects)
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aPhoto = fetchedResultsController.object(at: indexPath)
        
        //            let aPhoto = Test.test[indexPath.row]
        
        let reuseIdentifier = "PhotoAlbumCollectionViewCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        
        
        cell.photoImageView.image = UIImage(data: aPhoto.photo!)
        
        cell.backgroundColor = .black
        
        //            print(aPhoto.individualPhotos)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("shizzle working")
        
        print(fetchedResultsController.fetchedObjects?.count)
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        try? fetchedResultsController.performFetch()
        print(fetchedResultsController.fetchedObjects?.count)
        
        self.collectionView.deleteItems(at: [indexPath])
//        self.collectionView.reloadData()
        
        
    }
    
    
    
    
}
//
//extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
//
//
//}
