//
//  NetworkParameters.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation

class NetworkParameters {
    
    static let flickrAPIKey = "a8c1a3376e1e8bb66fd10e35623a5712"
    
    static let flickerSecret = "374afca4470227a1"
        
    enum Endpoints {
        
        
        static let base = "https://www.flickr.com/services/rest/?method="
        static let search = "flickr.photos.search"
        static let json = "&format=json&nojsoncallback=1"
        
        // Add random page number later
        static let basePage = "&page=1"
        static let perPage = "&per_page=12"
        static let basePageNumber = 1
        static var ceilingPageNumber:UInt32 = 1
        static var randomPage:UInt32 = 1
//
//        func randomPageMethod(number: UInt32) -> UInt32 {
//
//            return arc4random_uniform(number)
//
//        }
        
    case photosSearch(Double, Double)
        case imageURL(String, Int, String, String)
        case pageNumberSearch(Double, Double)
        
        var stringValue: String {
            
            switch self {
                
                //Probably can sort this together
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

