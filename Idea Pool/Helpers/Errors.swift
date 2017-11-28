//
//  Errors.swift
//  Idea Pool
//
//  Created by Arpit Williams on 27/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Data Errors
enum DataError: Error {
    case InvalidKey(String?)
}

// Request Errors
enum RequestError: Error {
    case InvalidBody
    case InvalidParameters
    case InvalidURL
}

// Response Errors
enum ResponseError: Error {
    case InvalidData
    case InvalidJSON
    case InvalidKey(String?)
    case InvalidResponseCode(Any?)
}
