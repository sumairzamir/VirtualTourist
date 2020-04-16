//
//  NetworkGetRequests.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 12/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit

class NetworkGetRequests {

    class func requestNumberOfPages(lat: Double, long: Double, completionHandler: @escaping (Bool, Int?, Error?) -> Void) {
        
        
        let task = URLSession.shared.dataTask(with: NetworkParameters.Endpoints.pageNumberSearch(lat, long).url) { (data, response, error) in
            guard let data = data else {
                completionHandler(false, nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let response = try decoder.decode(PhotosSearchResponse.self, from: data)
        
                let pages = response.photos.pages
                
                print(pages)
                
                completionHandler(true, pages, nil)
                
            } catch {
                
                completionHandler(false, nil, error)
            }
        }
        task.resume()
    
    }
    
    class func requestPhotoSearchByLatLon (lat: Double, long: Double, completionHandler: @escaping (Bool, [PhotosArray]?, Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: NetworkParameters.Endpoints.photosSearch(lat, long).url) { (data, response, error) in
            guard let data = data else {
                completionHandler(false, nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let response = try decoder.decode(PhotosSearchResponse.self, from: data)
                
                // Try to conver to URL image
                
                let photosContainer = response.photos
                let photosReceived = photosContainer.photo
                
                print(photosReceived)
//
//                let server = photosReceived.map { $0.server }
//                let secret = photosReceived.map { $0.secret }
//                let id = photosReceived.map { $0.id }
//                let farm = photosReceived.map { $0.farm }
//
//
//
//                let photoURLs = NetworkParameters.Endpoints.imageURL(id, farm, server, secret)
//
//                print(photoURLs)
                

                let photoArray: [PhotosArray] = photosReceived.compactMap { response in
                    guard
                        let server: String = response.server,
                        let secret: String = response.secret,
                        let farm: Int = response.farm,
                        let id: String = response.id
                    else {
                    return nil
                }

                    var photoArrayResponse = PhotosArray(id: id, secret: secret, server: server, farm: farm)

                let nextStepPhoto = NetworkParameters.Endpoints.imageURL(id, farm, server, secret).url

                    let imageData = try? Data(contentsOf: nextStepPhoto)
                    
                    let image = UIImage(data: imageData!)
                    
                    photoArrayResponse.individualPhotos = image
                    
                    return photoArrayResponse

                }
                
//                print(photo)
                
//                print(photoArray)
                completionHandler(true, photoArray, nil)
                
                
            } catch {
                
                completionHandler(false, nil, error)
                
            }
            
        }
        
        task.resume()


    }
//
//    class func requestImageFiles (url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let data = data else {
//                completionHandler(nil, error)
//                return
//            }
//
//
//        let photos = UIImage(data: data)
//
//        completionHandler(photos,nil)
//
//        }
//
//        task.resume()
//
//    }
//
//
    
}
