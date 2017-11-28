//
//  Track.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// User model
struct User {
    let name: String
    let email: String
}

// User extension
extension User {
    
    // Initializer
    init(json: [String: Any]) throws {
        
        guard let name = json["name"] as? String else {
            throw DataError.InvalidKey("name")
        }
        guard let email = json["email"] as? String else {
            throw DataError.InvalidKey("email")
        }
        
        self.name = name
        self.email = email
    }
}
