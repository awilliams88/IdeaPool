//
//  Extensions.swift
//  Idea Pool
//
//  Created by Arpit Williams on 27/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation
import UIKit

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

// Returns the total sum of all elements in the array
extension Array where Element: Numeric {
    var total: Element { return reduce(0, +) }
}

// Returns the average of all elements of interger type in the array
extension Array where Element: BinaryInteger {
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}

// Returns the average of all elements of floating type in the array
extension Array where Element: FloatingPoint {
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

// NSMutable Attributed String
extension NSMutableAttributedString{
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(.foregroundColor, value: color, range: range)
        }
    }
}
