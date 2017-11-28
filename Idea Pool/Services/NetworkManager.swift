//
//  NetworkManager.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Network Manager services enable loading and parsing data from remote server
class NetworkManager {
    
    // Result handler closure
    public typealias ResultHandler = (Result<Any>) -> Void
    
    // Loads Data from the given url
    static func loadData(from url: String,
                         using body: [String: Any]?,
                         requestType: Constants.RequestType,
                         completion: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        
        // Validate URL
        guard let url  = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            throw RequestError.InvalidURL
        }
        
        // Construct URL Request
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        
        // Set Request Header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken = UserDefaults.standard.value(forKey: Constants.Keys.AccessToken) as? String{
            request.setValue("ACCESS_TOKEN=\(accessToken)", forHTTPHeaderField: "Cookie")
        }
        
        // Set Request Body
        if let body = body { 
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.httpBody = jsonData
            } catch {
                throw RequestError.InvalidBody
            }
        }
        
        // Load Request
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Call Completion handler
            completion(data, response, error)
        })
        task.resume()
    }
    
    // Validates Retrived Data and Response
    static func validate(responseCode: Constants.ResponseCode,
                         for data: Data?,
                         and response: URLResponse?,
                         completion: ResultHandler) {
        
        // Check for nil response data
        guard let data = data else {
            completion(Result.Failure(ResponseError.InvalidData))
            return
        }
        
        do {
            // Create valid json for data
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                // Validate response status code
                guard let statusCode = NetworkManager.statusCode(for: response),
                    statusCode == responseCode.rawValue else {
                        completion(Result.Failure(ResponseError.InvalidResponseCode(json.values.first)))
                        return
                }
                
                // Callback JSON Result
                completion(Result.Success(json))
            }
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Retrives status code for given response
    static func statusCode(for response: URLResponse?) -> Int? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        return response.statusCode
    }
}
