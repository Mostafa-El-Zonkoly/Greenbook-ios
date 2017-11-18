//
//  User.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class User: BaseModel {
    
    var name : String = ""
    var image_url : String = ""
    var password : String = ""
    var email : String = ""
    var token : String = ""
    var saved : Bool {
        return id != -1
    }

    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["name"] as? String {
            self.name = value
        }
        if let value = dict["image_url"] as? String {
            self.image_url = value
        }
        if let value = dict["email"] as? String {
            self.email = value
        }

        if let value = dict["password"] as? String {
            self.password = value
        }else{
            self.password = ""
        }
        if let value = dict["token"] as? String {
            self.token = value
        }
       
    }
}
