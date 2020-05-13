//
//  PhotosSearchResponse.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit

// As per Flickr API documentation,
struct PhotosSearchResponse: Codable {
    let photos: PhotosResponse
}

struct PhotosResponse: Codable {
    let pages: Int
    let photo: [PhotoLevelResponse]
}

struct PhotoLevelResponse: Codable, Equatable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    // URL variable added and called on the GET request for URL components.
    var url: URL?
}
