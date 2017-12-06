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
                          message: String,
                          actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alert.addAction(action)
        }
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
