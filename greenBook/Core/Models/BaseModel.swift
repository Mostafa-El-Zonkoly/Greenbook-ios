//
//  AbstractObject.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class BaseModel : NSObject {
    var id : Int = -1
    // Func used to convert the object to dictionary
    func getDict(exceptKeys: [String]) -> [String : Any]{
        var dict : [String : Any] = [:]
        var mirrored_object = Mirror(reflecting: self)
        print(mirrored_object)
        
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                if !exceptKeys.contains(property_name) {
                    dict[property_name] = attr.value
                }
            }
        }
        while (mirrored_object.superclassMirror != nil){
            if let parent = mirrored_object.superclassMirror {
                mirrored_object = parent
                for (_, attr) in mirrored_object.children.enumerated() {
                    if let property_name = attr.label as String! {
                        if !exceptKeys.contains(property_name) {
                            dict[property_name] = attr.value
                        }
                    }
                }
            }
        }
        
        return dict
    }
    
    func bindDictionary(dict : [String : Any]) {
        if let value = dict["id"] as? Int {
            self.id = value
        }
    }
    func toDict() -> [String : Any]{
        return getDict(exceptKeys: [])
    }
}
