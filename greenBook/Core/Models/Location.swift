//
//  Location.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class Location : BaseModel {
    var lat : Double = 0
    var long : Double = 0
    var address : String = ""
    
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["lat"] as? Double {
            self.lat = value
        }
        if let value = dict["long"] as? Double {
            self.long = value
        }
        if let value = dict["address"] as? String {
            self.address = value
        }
    }
}
