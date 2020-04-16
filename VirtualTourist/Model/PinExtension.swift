//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Aiman Nabeel on 14/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        
        let lat = latitude
        let long = longitude
        
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    
    }
    
}
