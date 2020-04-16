//
//  PhotosSearch.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation

struct PhotosSearchRequest: Codable {
    
    let APIKey: String
    let lat: Double
    let long: Double
    
    enum CodingKeys: String, CodingKey {
        
        case APIKey = "api_key"
        case lat
        case long
        
    }
    
}

