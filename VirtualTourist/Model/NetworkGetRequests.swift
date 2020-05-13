//
//  NetworkGetRequests.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import Alamofire

class NetworkGetRequests {
    
    // This GET request uses the latitude and longitude from the selected pin and returns the number of image pages available.
    class func requestNumberOfPages(lat: Double, long: Double, completionHandler: @escaping (Bool, Int?, Error?) -> Void) {
        // Alamo removes need for defined generic request and closures passed through execute on the main thread.
        AF.request(NetworkParameters.Endpoints.pageNumberSearch(lat, long).url).responseDecodable(of: PhotosSearchResponse.self) { (response) in
            if let response = response.value {
                let pageNumberResponse = response.photos.pages
                completionHandler(true, pageNumberResponse, nil)
            } else {
            completionHandler(false, nil, response.error)
            }
        }
    }
    
    // This GET request supplies the same latitude and longitude as above and returns an array of URLs.
    class func requestPhotoSearch (lat: Double, long: Double, completionHandler: @escaping (Bool, [PhotoLevelResponse]?, Error?) -> Void) {
        AF.request(NetworkParameters.Endpoints.photosSearch(lat, long).url).responseDecodable(of: PhotosSearchResponse.self) { (response) in
            if let response = response.value {
                          // Return the response as an array of URL components per photo.
                          let photoURLComponents = response.photos.photo
                          // Map the array of URL components and define them.
                          let photoURLToImageReturn: [PhotoLevelResponse] = photoURLComponents.compactMap { response in
                              guard
                                  let server: String = response.server,
                                  let secret: String = response.secret,
                                  let farm: Int = response.farm,
                                  let id: String = response.id
                                  else {
                                      return nil
                              }
                              // For each photo, use the URL components to construct the image URLs.
                              let constructImageURLs = NetworkParameters.Endpoints.imageURL(id, farm, server, secret).url
                              // Instantiate the URLs back into the array within url constant.
                              let initPhotoURLs = PhotoLevelResponse(id: id, secret: secret, server: server, farm: farm, url: constructImageURLs)
                              return initPhotoURLs
                          }
                          completionHandler(true, photoURLToImageReturn, nil)
                      } else {
                completionHandler(false, nil, response.error)
                      }
        }
    }
    
}
