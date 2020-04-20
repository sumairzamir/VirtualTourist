//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 14/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import MapKit
import CoreData

/*
 Extention to the Pin entity, which adds conformance to CLLocationCoordinate2D.
 This allows Pin entities to be fetched and placed as annotations.
 Pin entity attributes of latitude and longitude are defined below.
 */
extension Pin: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        let lat = latitude
        let long = longitude
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
}
