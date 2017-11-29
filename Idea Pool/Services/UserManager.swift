
//
//  UserManager.swift
//  Idea Pool
//
//  Created by Arpit Williams on 26/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Provides services related to user registration and authentication
class UserManager {
    
    // MARK: Properties
    
    // Private initializer for Singleton Class
    private init(){}
    
    // Singleton property
    static let shared = UserManager()
    
    // Currently logged in user
    var currentUser: User?
    
    // MARK: Methods
    
    // Registers new user: Returns -> Current user|error in Result Handler
    func register(_ userInfo: [String: Any], completion: @escaping NetworkManager.ResultHandler)  {
        
        // Guard request parameters
        guard let name = userInfo["name"],
            let email = userInfo["email"],
            let password = userInfo["password"] else {
                completion(Result.Failure(RequestError.InvalidParameters))
                return
        }
        
        // Construct url and request body
        let url = Constants.URL.baseURL+Constants.EndPoints.Users
        let body = ["name": name,
                    "email": email,
                    "password": password]
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: body, requestType: .POST, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Created, for: data, and: response, completion: { (result) in
                    do {
                        // Update token
                        try NetworkManager.updateToken(for: result)
                        
                        // Callback result
                        self.updateCurrentUser({ (result) in completion(result) })
                    }
                    catch {
                        completion(Result.Failure(error))
                    }
                })
            })
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Login existing user: Returns -> Current user|error in completion closure
    func login(_ userInfo: [String: Any], completion: @escaping NetworkManager.ResultHandler) {
        
        // Guard request parameters
        guard let email = userInfo["email"],
            let password = userInfo["password"] else {
                completion(Result.Failure(RequestError.InvalidParameters))
                return
        }
        
        // Construct url and request body
        let url = Constants.URL.baseURL+Constants.EndPoints.AccessToken
        let body = ["email": email,
                    "password": password]
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: body, requestType: .POST, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Created, for: data, and: response, completion: { (result) in
                    do {
                        // Update token
                        try NetworkManager.updateToken(for: result)
                        
                        // Callback result
                        self.updateCurrentUser({ (result) in completion(result) })
                    }
                    catch {
                        completion(Result.Failure(error))
                    }
                })
            })
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Logs out by deleting access token and current user
    func logout() {
        
        // Remove locally stored tokens
        NetworkManager.removeTokens()
        
        // Set current user to nil
        currentUser = nil
        
        // Guard resfreshToken
        guard let resfreshToken = UserDefaults.standard.value(forKey: Constants.ResponseKeys.RefreshToken) else { return }
        
        // Construct request url and body
        let url = Constants.URL.baseURL+Constants.EndPoints.AccessToken
        let body = ["refresh_token": resfreshToken]
        
        // Load request to delete access token from server
        try? NetworkManager.loadData(from: url, using: body, requestType: .DELETE, completion: {_,_,_ in })
    }
    
    // Updates current user info: Returns -> Current user|error in Result Handler
    fileprivate func updateCurrentUser(_ completion: @escaping NetworkManager.ResultHandler) {
        do {
            // Load Data
            let url = Constants.URL.baseURL+Constants.EndPoints.CurrentUser
            try NetworkManager.loadData(from: url, using: nil, requestType: .GET, completion: { (data, response, error) in
                
                // Validate Response
                NetworkManager.validate(responseCode: .Ok, for: data, and: response, completion: { (result) in
                    do {
                        if let result = try result.unwrap() as? [String: Any] {
                            do {
                                // Create and Callback current user
                                self.currentUser = try User(json: result)
                                completion(Result.Success(self.currentUser as Any))
                            }
                            catch {
                                completion(Result.Failure(error))
                            }
                        }
                    }
                    catch {
                        completion(Result.Failure(error))
                    }
                })
            })
        } catch {
            completion(Result.Failure(error))
        }
    }
}
