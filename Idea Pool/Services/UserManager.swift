
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
    
    // Register new user
    // Returns -> Current user/error in Result Handler
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
            try NetworkManager.loadData(from: url,
                                        using: body,
                                        requestType: .POST,
                                        completion:
                { (data, response, error) in
                    
                    // Validate response
                    NetworkManager.validate(responseCode: .Created,
                                            for: data,
                                            and: response,
                                            completion:
                        { (result) in
                            do {
                                // Update token
                                try self.updateToken(for: result)
                                
                                // Callback current user in completion handler
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
    
    // Login existing user
    // Returns -> Current user/error in completion closure
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
            try NetworkManager.loadData(from: url,
                                        using: body,
                                        requestType: .POST,
                                        completion:
                { (data, response, error) in
                    
                    // Validate response
                    NetworkManager.validate(responseCode: .Created,
                                            for: data,
                                            and: response,
                                            completion:
                        { (result) in
                            do {
                                // Update token
                                try self.updateToken(for: result)
                                
                                // Call back current user
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
        
        // Refresh token for current method if token is invalid
        if !isTokenValid() {
            
            // Refresh token for current method
            refreshToken(for: { self.logout() })
            return
        }
        
        // Guard resfreshToken
        guard let resfreshToken = UserDefaults.standard.value(forKey: Constants.Keys.RefreshToken) else { return }
        
        // Remove locally stored tokens
        removeTokens()
        
        // Set current user to nil
        currentUser = nil
        
        // Construct request url and body
        let url = Constants.URL.baseURL+Constants.EndPoints.AccessToken
        let body = ["refresh_token": resfreshToken]
        
        // Load request to delete access token from server
        try? NetworkManager.loadData(from: url,
                                     using: body,
                                     requestType: .DELETE,
                                     completion: {_,_,_ in })
    }
    
    // Updates current user info
    // Returns -> Current user|error in Result Handler
    fileprivate func updateCurrentUser(_ completion: @escaping NetworkManager.ResultHandler) {
        
        // Refresh token for current method if token is invalid
        if !isTokenValid() {
            refreshToken(for: { self.updateCurrentUser(completion) })
            return
        }
        
        do {
            // Load Data
            let url = Constants.URL.baseURL+Constants.EndPoints.CurrentUser
            try NetworkManager.loadData(from: url,
                                        using: nil,
                                        requestType: .GET,
                                        completion:
                { (data, response, error) in
                    
                    // Validate Response
                    NetworkManager.validate(responseCode: .Ok,
                                            for: data,
                                            and: response,
                                            completion:
                        { (result) in
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
    
    // Checks if current access token has expired or not
    fileprivate func isTokenValid() -> Bool {
        if let tokenTimeStamp = UserDefaults.standard.value(forKey: Constants.Keys.TokenTimestamp) as? Double {
            let timeDifference = (Date.timeIntervalSinceReferenceDate - tokenTimeStamp) / 60 // In minutes
            if timeDifference > 8 {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    // Refreshes access token and executes passed in closure
    fileprivate func refreshToken(for closure: @escaping () -> ()) {
        
        // Guard resfreshToken token for validating login state
        guard let resfreshToken = UserDefaults.standard.value(forKey: Constants.Keys.RefreshToken) else {
            return
        }
        
        // Construct request url and body
        let url = Constants.URL.baseURL+Constants.EndPoints.RefreshAccessToken
        let body = ["refresh_token": resfreshToken]
        
        do {
            // Load Data
            try NetworkManager.loadData(from: url,
                                        using: body,
                                        requestType: .POST,
                                        completion:
                { (data, response, error) in
                    
                    // Validate response
                    NetworkManager.validate(responseCode: .Ok,
                                            for: data,
                                            and: response,
                                            completion:
                        { (result) in
                            do {
                                // Update token
                                try self.updateToken(for: result)
                                closure()
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                    })
            })
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // Updates and Stores token in user defaults
    fileprivate func updateToken(for result: Result<Any>) throws {
        do {
            if let json = try result.unwrap() as? [String: Any] {
                
                // Store tokens
                guard let accessToken = json[Constants.Keys.AccessToken] as? String else {
                    throw DataError.InvalidKey(Constants.Keys.AccessToken)
                }
                UserDefaults.standard.set(accessToken, forKey: Constants.Keys.AccessToken)
                UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: Constants.Keys.TokenTimestamp)
                
                if let refreshToken = json[Constants.Keys.RefreshToken] as? String  {
                    UserDefaults.standard.set(refreshToken, forKey: Constants.Keys.RefreshToken)
                }
            }
        }
        catch {
            throw error
        }
    }
    
    // Removes stored tokens
    fileprivate func removeTokens() {
        UserDefaults.standard.removeObject(forKey: Constants.Keys.AccessToken)
        UserDefaults.standard.removeObject(forKey: Constants.Keys.RefreshToken)
        UserDefaults.standard.removeObject(forKey: Constants.Keys.TokenTimestamp)
    }
}
