//
//  Utility.swift
//  Idea Pool
//
//  Created by Arpit Williams on 30/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import Foundation
import UIKit

// Utility class modularizes common tasks related to view controllers
class Utility {
    
    // Present alert for VC
    static func showAlert(for vc: UIViewController,
                          title: String,
                          message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
