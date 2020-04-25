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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newPhotoCollectionButton: UIButton!
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    let numberOfCollectionViewItems = 12
    
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
        return numberOfCollectionViewItems
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Determine whether a valid indexPath exists first. Otherwise placeholder image remains.
        if self.validateIndexPath(indexPath) {
            let photoToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(photoToDelete)
            try? dataController.viewContext.save()
            let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
            cell.photoImageView.image = UIImage(named: "placeholderImage")
            // The following fetch and update to the CollectionView is monitored by the ResultsFetchController Delegate.
            // try? fetchedResultsController.performFetch()
            // self.photoCollectionView.deleteItems(at: [indexPath])
        }
    }
    
    @IBAction func fetchNewPhotoCollection(_ sender: Any) {
        newPhotoCollectionButton.isEnabled = false
        photoCollectionView.isUserInteractionEnabled = false
        deletePhotos()
        // Run the network request again to obtain new photos.
        NetworkGetRequests.requestNumberOfPages(lat: pin.latitude, long: pin.longitude, completionHandler: handleNetworkRequest(success:response:error:))
    }
    // Helper method to remove all photos from the store.
    func deletePhotos() {
        let photosFetched = fetchedResultsController.fetchedObjects
        for photos in photosFetched! {
            dataController.viewContext.delete(photos)
            try? dataController.viewContext.save()
        }
    }
    // This method compares the indexPath returned to the number of objects.
    func validateIndexPath(_ indexPath: IndexPath) -> Bool {
        if let sections = self.fetchedResultsController?.sections {
            /*
             If the indexPath row passed is less than the number of objects in the FRC then a true is returned.
             Specifically for the dequed cells.
             If the indexPath for the cell is higher than the number of objects, the cell is not updated.
             This forces the rows to be udpated in sequence.
             */
            if indexPath.row < sections[0].numberOfObjects {
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
        // BinaryData cannot be sorted, another attribute needs to be created as the FRC needs a sort descriptor.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
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
            // Download the images as an async task.
            DispatchQueue.global().async {
                for URLs in response! {
                    let downloadedImageData = try? Data(contentsOf: URLs.url!)
                    let downloadedImage = UIImage(data:downloadedImageData!)
                    let photo = Photos(context: self.dataController.viewContext)
                    photo.photo = downloadedImage?.pngData()
                    photo.creationDate = Date()
                    photo.pin = self.pin
                    try? self.dataController.viewContext.save()
                    // The following fetch and reload is handled by the fetched results controller
                    // try? self.fetchedResultsController.performFetch()
                    // DispatchQueue.main.async {
                    //      photoCollectionView.reloadData()
                    // }
                }
                DispatchQueue.main.async {
                    self.newPhotoCollectionButton.isEnabled = true
                    self.photoCollectionView.isUserInteractionEnabled = true
                }
            }
        } else {
            print("Unable to download images.")
        }
    }
}
// Use of the resultsfetchcontroller rather than performing fetches within the controller.
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollectionView.reloadData()
            break
        default:
            break
        }
    }
    
}
