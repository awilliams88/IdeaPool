//
//  NetworkManager.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Network Manager services controls loading of data from remote server
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
        
        // Check if access token exists
        if let accessToken = UserDefaults.standard.value(forKey: Constants.ResponseKeys.AccessToken) as? String {
            
            // Validate access token
            if isAccessTokenValid() == false {
                
                // Refresh invalid access token
                refreshToken(for: { try? loadData(from: url.absoluteString, using: body, requestType: requestType, completion: completion) })
                return
            } else {
                // Set Access Token to request header
                request.setValue("ACCESS_TOKEN=\(accessToken)", forHTTPHeaderField: "Cookie")
            }
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
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            completion(data, response, error)
        }).resume()
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
            // Create JSON
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Validate response code
            guard let statusCode = NetworkManager.statusCode(for: response), statusCode == responseCode.rawValue else {
                completion(Result.Failure(ResponseError.InvalidResponseCode(json)))
                return
            }
            
            // Callback JSON
            completion(Result.Success(json))
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Retrives status code for response
    static func statusCode(for response: URLResponse?) -> Int? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        return response.statusCode
    }
    
    // Validates access token
    static func isAccessTokenValid() -> Bool? {
        if let tokenTimeStamp = UserDefaults.standard.value(forKey: Constants.ResponseKeys.TokenTimestamp) as? Double {
            let timeDifference = (Date.timeIntervalSinceReferenceDate - tokenTimeStamp) / 60 // In minutes
            if timeDifference > 8 {
                return false
            } else {
                return true
            }
        }
        return nil
    }
    
    // Refreshes access token and executes passed in closure
    static func refreshToken(for closure: @escaping () -> ()) {
        
        let urlString = Constants.URL.baseURL+Constants.EndPoints.RefreshAccessToken
        
        // Guard url and tokens for request
        guard let url  = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!),
            let resfreshToken = UserDefaults.standard.value(forKey: Constants.ResponseKeys.RefreshToken),
            let accessToken = UserDefaults.standard.value(forKey: Constants.ResponseKeys.AccessToken)
            else { return }
        
        // Construct URL Request
        var request = URLRequest(url: url)
        request.httpMethod = Constants.RequestType.POST.rawValue
        
        // Request Body
        let body = ["refresh_token": resfreshToken]
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpBody = jsonData
        
        // Set Request Header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ACCESS_TOKEN=\(accessToken)", forHTTPHeaderField: "Cookie")
        
        // Load Request
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // Validate response
            NetworkManager.validate(responseCode: .Ok, for: data,and: response, completion: { (result) in
                do {
                    // Update token
                    try NetworkManager.updateToken(for: result)
                    
                    // Execute closure
                    closure()
                }
                catch {
                    print(error.localizedDescription)
                }
            })
        }).resume()
    }
    
    // Updates and Stores token in user defaults
    static func updateToken(for result: Result<Any>) throws {
        do {
            if let json = try result.unwrap() as? [String: Any] {
                
                // Store Refresh Token
                if let refreshToken = json[Constants.ResponseKeys.RefreshToken] as? String  {
                    UserDefaults.standard.set(refreshToken, forKey: Constants.ResponseKeys.RefreshToken)
                }
                
                // Guard and Store Access Tokens
                guard let accessToken = json[Constants.ResponseKeys.AccessToken] as? String else {
                    throw DataError.InvalidKey(Constants.ResponseKeys.AccessToken)
                }
                UserDefaults.standard.set(accessToken, forKey: Constants.ResponseKeys.AccessToken)
                UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: Constants.ResponseKeys.TokenTimestamp)
            }
        }
        catch {
            throw error
        }
    }
    
    // Removes stored tokens
    static func removeTokens() {
        UserDefaults.standard.removeObject(forKey: Constants.ResponseKeys.AccessToken)
        UserDefaults.standard.removeObject(forKey: Constants.ResponseKeys.RefreshToken)
        UserDefaults.standard.removeObject(forKey: Constants.ResponseKeys.TokenTimestamp)
    }
}
