//
//  Category.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class Category: BaseModel {
    var name : String = ""
    
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["name"] as? String {
            self.name = value
        }else{
            self.name = ""
        }
    }
}
