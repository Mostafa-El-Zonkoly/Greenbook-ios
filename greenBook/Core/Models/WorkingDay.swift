//
//  WorkingDay.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
class WorkingDay : BaseModel {
    var day_name : String = ""
    var opened_at : String = ""
    var closed_at : String = ""
    var state : String = ""
    
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        
        if let value = dict["day_name"] as? String {
            self.day_name = value
        }
        
        if let value = dict["opened_at"] as? String {
            self.opened_at = value
        }
        
        if let value = dict["closed_at"] as? String {
            self.closed_at = value
        }
        if let value = dict ["state"] as? String {
            self.state = value
        }
    }
}
