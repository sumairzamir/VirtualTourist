//
//  PhotosSearchResponse.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit

struct PhotosSearchResponse: Codable {

    let photos: PhotosResponse

}
    struct PhotosResponse: Codable {

        let pages: Int //Separate out later...so don't do request twice
        let photo: [PhotoLevelResponse]

    }

struct PhotoLevelResponse: Codable, Equatable {

    let id: String
    let secret: String
    let server: String
    let farm: Int

}

struct PhotosArray: Equatable {
    
    var individualPhotos: UIImage?
    let id: String
    let secret: String
    let server: String
    let farm: Int

}

