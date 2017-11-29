//
//  IdeaManager.swift
//  Idea Pool
//
//  Created by Arpit Williams on 29/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Provides services to perform CRUD operation on Ideas
class IdeaManager {
    
    // MARK: Properties
    
    // Private initializer for Singleton Class
    private init(){}
    
    // Singleton property
    static let shared = IdeaManager()
    
    // MARK: Methods
    
    // Creates new idea: Returns -> Created Idea or Error in Result Handler
    func create(with content: String,
                    confidence: Int,
                    ease: Int,
                    impact: Int,
                    completion: @escaping NetworkManager.ResultHandler)  {
        
        // Construct url and request body
        let url = Constants.URL.baseURL+Constants.EndPoints.Ideas
        let body: [String: Any] = ["confidence": confidence,
                                   "ease": ease,
                                   "impact": impact,
                                   "content": content]
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: body, requestType: .POST, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Created, for: data, and: response, completion: { (result) in
                    do {
                        if let result = try result.unwrap() as? [String: Any] {
                            do {
                                // Create and return new idea from result
                                completion(Result.Success(try Idea(json: result) as Any))
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
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Reads Ideas at page: Returns -> Array of Ideas or Error in Result Handler
    func read(at page: Int, completion: @escaping NetworkManager.ResultHandler) {
        
        // Construct url
        let url = Constants.URL.baseURL+Constants.EndPoints.Ideas+"?page=\(page)"
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: nil, requestType: .GET, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Ok, for: data, and: response, completion: { (result) in
                    do {
                        if let result = try result.unwrap() as? [[String: Any]] {
                            
                            // Create and return array of ideas for each result
                            var ideas = [Idea]()
                            for each in result {
                                if let idea = try? Idea(json: each) {
                                    ideas.append(idea)
                                }
                            }
                            completion(Result.Success(ideas))
                        }
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
    
    // Updates Idea: Returns -> updated Idea or Error in Result Handler
    func update(_ idea: Idea,
                 with content: String,
                 confidence: Int,
                 ease: Int,
                 impact: Int,
                 completion: @escaping NetworkManager.ResultHandler) {
        
        // Guard Idea Identifier
        guard let identifier = idea.id else { return }
        
        // Construct URL and request body
        let url = Constants.URL.baseURL+Constants.EndPoints.Ideas+"/"+identifier
        let body: [String: Any] = ["confidence": confidence,
                                   "ease": ease,
                                   "impact": impact,
                                   "content": content]
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: body, requestType: .PUT, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Ok, for: data, and: response, completion: { (result) in
                    do {
                        if let result = try result.unwrap() as? [String: Any] {
                            do {
                                // Create and return new idea from result
                                completion(Result.Success(try Idea(json: result) as Any))
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
        }
        catch {
            completion(Result.Failure(error))
        }
    }
    
    // Deletes Idea
    func delete(_ idea: Idea, completion: @escaping NetworkManager.ResultHandler) {
        
        // Guard Idea Identifier
        guard let identifier = idea.id else { return }
        
        // Construct URL
        let url = Constants.URL.baseURL+Constants.EndPoints.Ideas+"/"+identifier
        do {
            // Load Data
            try NetworkManager.loadData(from: url, using: nil, requestType: .DELETE, completion: { (data, response, error) in
                
                // Validate response
                NetworkManager.validate(responseCode: .Deleted, for: data, and: response, completion: { (result) in
                    
                    // Callback result
                    completion(result)
                })
            })
        }
        catch {
            completion(Result.Failure(error))
        }
    }
}
