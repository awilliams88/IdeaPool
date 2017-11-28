//
//  DownloadManager.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation
import UIKit

// Provides services for downloading and caching remote resources
class DownloadManager {
    
    // Private image caching class property
    fileprivate static let imageCache = NSCache<NSString, UIImage>()
    
    // Fetches cached or new images for the given url
    static func downloadImage(at url: URL,
                              with completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            DownloadManager.downloadData(url: url) { data, response, error in
                
                // Check for error
                guard error ==  nil else {
                    completion(nil, error)
                    return
                }
                
                // Check for invalid reponse data
                guard let data = data, let image = UIImage(data: data) else {
                    completion(nil, ResponseError.InvalidData)
                    return
                }
                
                // Save and return uiimage from response data
                imageCache.setObject(image, forKey: url.absoluteString as NSString)
                completion(image, nil)
            }
        }
    }
    
    // Private method to download data from given url with Ephemeral Configuration
    fileprivate static func downloadData(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession(configuration: .ephemeral).dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}



