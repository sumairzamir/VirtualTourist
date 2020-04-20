//
//  NetworkParameters.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation

class NetworkParameters {
    
    // Flickr related parameters.
    static let flickrAPIKey = "a8c1a3376e1e8bb66fd10e35623a5712"
    static let flickerSecret = "374afca4470227a1"
    
    enum Endpoints {
        
        static let base = "https://www.flickr.com/services/rest/?method="
        static let search = "flickr.photos.search"
        static let json = "&format=json&nojsoncallback=1"
        
        // Parameter necessary to request the total number of pages per location.
        static let basePage = "&page=1"
        
        // Parameters used to save a random page number.
        static var ceilingPageNumber:UInt32 = 1
        static var randomPage:UInt32 = 1
        
        // The network request is limited to 12 items per page. This is the number used within the app.
        static let perPage = "&per_page=12"
        
        // Endpoint to return the number of pages per location selected.
        case pageNumberSearch(Double, Double)
        
        // Endpoint to return URL components for the selected location as per a random page used.
        case photosSearch(Double, Double)
        
        // Endpoint to define the URL from the URL components downloaded.
        case imageURL(String, Int, String, String)
        
        var stringValue: String {
            switch self {
            case .pageNumberSearch(let lat, let long):
                return Endpoints.base + Endpoints.search + "&api_key=\(flickrAPIKey)" + "&lat=\(lat)" + "&lon=\(long)" + Endpoints.json + Endpoints.basePage + Endpoints.perPage
            case .photosSearch(let lat, let long):
                return Endpoints.base + Endpoints.search + "&api_key=\(flickrAPIKey)" + "&lat=\(lat)" + "&lon=\(long)" + Endpoints.json + "&page=\(Endpoints.randomPage)" + Endpoints.perPage
            case .imageURL(let photoId, let farm, let server, let secret):
                return "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
}

