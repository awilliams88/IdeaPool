//
//  Idea.swift
//  Idea Pool
//
//  Created by Arpit Williams on 29/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// User model
struct Idea {
    let id: String?
    let timestamp: Double?
    let content: String
    
    let confidence: Int
    let ease: Int
    let impact: Int
    let averageScore: Double
}

// User extension
extension Idea {
    
    // Initializer
    init(json: [String: Any]) throws {
        
        if let id = json["id"] as? String {
            self.id = id
        } else {
            self.id = nil
        }
        if let timestamp = json["created_at"] as? Double {
            self.timestamp = timestamp
        } else {
            self.timestamp = nil
        }
        guard let content = json["content"] as? String else {
            throw DataError.InvalidKey("content")
        }
        guard let impact = json["impact"] as? Int else {
            throw DataError.InvalidKey("impact")
        }
        guard let ease = json["ease"] as? Int else {
            throw DataError.InvalidKey("ease")
        }
        guard let confidence = json["confidence"] as? Int else {
            throw DataError.InvalidKey("impact")
        }
        self.content = content
        self.impact = impact
        self.ease = ease
        self.confidence = confidence
        self.averageScore = [confidence, ease, impact].average
    }
}
