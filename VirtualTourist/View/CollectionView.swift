//
//  CollectionView.swift
//  VirtualTourist
//
//  Created by Aiman Nabeel on 15/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit

class CollectionView: UICollectionView {
    

        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return Test.test.count
    //        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
    //        let aPhoto = fetchedResultsController.object(at: indexPath)
            
            let aPhoto = Test.test[indexPath.row]
            
            let reuseIdentifier = "PhotoAlbumCollectionViewCell"
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
            
            
            
            cell.photoImageView.image = aPhoto.individualPhotos
            
            print(aPhoto.individualPhotos)
            
            return cell
        }
        
        
    
    
    
    
}
