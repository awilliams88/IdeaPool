//
//  Constants.swift
//  MJ Tracks
//
//  Created by Arpit Williams on 16/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Struct to store all constants properties
struct Constants {
    
    // URL EndPoints
    struct URL {
        static let baseURL = "https://small-project-api.herokuapp.com"
    }
    
    // EndPoints
    struct EndPoints {
        static let AccessToken = "/access-tokens"
        static let CurrentUser = "/me"
        static let Ideas = "/ideas"
        static let RefreshAccessToken = "/access-tokens/refresh"
        static let Users = "/users"
    }
    
    // Request Type
    enum RequestType: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    // Response Code
    enum ResponseCode: Int {
        case Ok = 200
        case Created = 201
        case Deleted = 204
    }
    
    // Keys : Value matches to server response keys
    struct ResponseKeys {
        static let AccessToken = "jwt"
        static let RefreshToken = "refresh_token"
        static let TokenTimestamp = "token_timestamp"
    }
    
    // Segues
    struct Segue {
        static let showIdeasVC = "showIdeasVC"
        static let showIdeaEditorVC = "showIdeaEditorVC"
        static let unwindToIdeasVC = "unwindToIdeasVC"
    }
    
    // Label
    struct Label {
        static let SignIn = "Log In"
        static let SignUp = "Sign Up"
        static let SignInInfo = "Already have an account? Log in"
        static let SignUpInfo = "Don’t have an account? Create an account"
        static let deleleAlertTitle = "Are you sure?"
        static let deleleAlertMessage = "This idea will be permanently deleted."
    }
}






