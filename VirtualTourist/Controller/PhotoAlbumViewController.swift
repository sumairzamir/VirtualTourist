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

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        // The network request is only called if the number of fetched objects is 0.
        if fetchedResultsController.fetchedObjects!.count == 0 {
            NetworkGetRequests.requestNumberOfPages(lat: pin.latitude, long: pin.longitude, completionHandler: handleNetworkRequest(success:response:error:))
        }
        // Adjust the MapView based on the pin selected from the previous controller.
        let coordinates = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let fixedSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let setRegion = MKCoordinateRegion(center: coordinates, span: fixedSpan)
        collectionMapView.setRegion(setRegion, animated: false)
        collectionMapView.addAnnotation(pin)
        collectionMapView.isUserInteractionEnabled = false
        // Collection view delegation.
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        // CollectionView FlowLayout parameters. NOTE: Remember to set custom size as "None" in storyboard.
        let space:CGFloat = 0
        // Sets width as 3 items per row of the CollectionView.
        let width = (photoCollectionView.frame.size.width - (2 * space))/3
        // Sets height as 4 items per column of the CollectionView.
        let height = (photoCollectionView.frame.size.height - (3 * space))/4
        self.photoCollectionViewFlowLayout.minimumInteritemSpacing = space
        self.photoCollectionViewFlowLayout.minimumLineSpacing = space
        self.photoCollectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    @IBAction func dismissPhotoAlbumView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // The CollectionView always shows 12 items, with the placeholder image shown on item deletion.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "PhotoAlbumCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        // The placeholder image is shown when an image is not yet downloaded.
        cell.photoImageView.image = UIImage(named: "placeholderImage")
        cell.photoImageView.alpha = 0.5
        cell.photoImageView.contentMode = .scaleAspectFit
        /*
         Determine whether a valid indexPath exists to present the image.
         This is determined using the helper function validateIndexPath.
         This overcomes the reusable cell behaviour which prevents sync to indexPath.
         */
        if self.validateIndexPath(indexPath) {
            let aPhoto = self.fetchedResultsController?.object(at: indexPath)
            cell.photoImageView.image = UIImage(data: aPhoto!.photo!)
            cell.photoImageView.alpha = 1
            cell.photoImageView.contentMode = .scaleAspectFill
        }
        return cell
    }
    // TO FIX!!!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        try? fetchedResultsController.performFetch()
        self.photoCollectionView.deleteItems(at: [indexPath])
    }
    
    @IBAction func fetchNewPhotoCollection(_ sender: Any) {
        let photosFetched = fetchedResultsController.fetchedObjects
        // Delete the photos already fetched from the FRC>
        for photos in photosFetched! {
            dataController.viewContext.delete(photos)
        }
        try? dataController.viewContext.save()
        // Run the network request again to obtain new photos.
        NetworkGetRequests.requestNumberOfPages(lat: pin.latitude, long: pin.longitude, completionHandler: handleNetworkRequest(success:response:error:))
    }
    // TO DO
    func validateIndexPath(_ indexPath: IndexPath) -> Bool {
        /*
         self.fetchedResultsController?.sections
         indexPath.section
         sections.count
         indexPath.row
         sections[indexPath.section].numberOfObjects
         */
        if let sections = self.fetchedResultsController?.sections, indexPath.section < sections.count {
            if indexPath.row < sections[indexPath.section].numberOfObjects {
                return true
            }
        }
        return false
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        // Predicate is needed to align the Photo entities to the Pin entities.
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func handleNetworkRequest(success: Bool, response: Int?, error: Error?) {
        if success {
            // Save the number of pages from the response.
            NetworkParameters.Endpoints.ceilingPageNumber = UInt32(response!)
            // Flickr responses do not appear to work after page number 335. Random page number is picked below this.
            if NetworkParameters.Endpoints.ceilingPageNumber > 335 {
                NetworkParameters.Endpoints.randomPage = arc4random_uniform(335) + 1
            } else {
                NetworkParameters.Endpoints.randomPage = arc4random_uniform(NetworkParameters.Endpoints.ceilingPageNumber) + 1
            }
            // After the random page number has been generated the request for URLs is then run.
            NetworkGetRequests.requestPhotoSearch(lat: pin.latitude, long: pin.longitude, completionHandler: handleURLRequest(success:response:error:))
        }
        else {
            print ("Unable to process network request.")
        }
    }
    
    func handleURLRequest(success: Bool, response: [PhotoLevelResponse]?, error: Error?) {
        if success {
            // Download the images as an asyn task.
            DispatchQueue.global().async {
                for URLs in response! {
                    let downloadedImageData = try? Data(contentsOf: URLs.url!)
                    let downloadedImage = UIImage(data:downloadedImageData!)
                    let photo = Photos(context: self.dataController.viewContext)
                    photo.photo = downloadedImage?.pngData()
                    photo.pin = self.pin
                    try? self.dataController.viewContext.save()
                    try? self.fetchedResultsController.performFetch()
                    // Return to the main thread and update the CollectionView.
                    DispatchQueue.main.async {
                        self.photoCollectionView.reloadData()
                    }
                }
            }
        } else {
            print("Unable to download images.")
        }
    }
}
