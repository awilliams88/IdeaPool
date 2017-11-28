//
//  Helpers.swift
//  Idea Pool
//
//  Created by Arpit Williams on 27/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Result Types - An enum for asynchronous error handling
// Refs: https://gist.github.com/BlameOmar/ead32cfdf7a1c27a7b5a
enum Result<T: Any> {
    case Success(T)
    case Failure(Error)
}
