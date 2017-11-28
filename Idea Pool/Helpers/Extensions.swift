//
//  Extensions.swift
//  Idea Pool
//
//  Created by Arpit Williams on 27/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation

// Extn. for Result Helper
// Ref: https://gist.github.com/BlameOmar/ead32cfdf7a1c27a7b5a
extension Result {
    
    init(_ f: () throws -> T) {
        do {
            self = .Success(try f())
        } catch let e {
            self = .Failure(e)
        }
    }
    
    func unwrap() throws -> T {
        switch self {
        case let .Success(x):
            return x
        case let .Failure(e):
            throw e
        }
    }
}
