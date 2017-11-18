//
//  Photo.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class Photo : BaseModel {
    
    var photo_url : String = ""
    func bindPhoto(dict : [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["photo_url"] as? String {
            self.photo_url = value
        }
    }
    
}
