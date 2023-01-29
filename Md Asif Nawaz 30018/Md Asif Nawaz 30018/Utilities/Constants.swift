//
//  Constants.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 12/1/23.
//

import Foundation
import UIKit

class Constants{
    
    static let catagories : [String] = ["All News","Health","Science","Sports","Business","Technology","Entertainment","General"]
    //static let apiKey = "21e422a61a7a46b080899d4a4ea1c4c1"
    //static let apiKey = "58aa2a7586654d32ae3156d87ea58859"
    static let apiKey = "19f1b8ec0f5e403cb050698d313d93f1"
    static func showAlert(msg:String) -> UIAlertController{
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { _ in
            
        }
        alert.addAction(action)
        return alert
    }
    
}


      
