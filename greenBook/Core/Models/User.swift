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
    var owned_shops_ids : [Int] = []
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
        if let values = dict["owned_shops"] as? [[String : Int]] {
            self.owned_shops_ids = []
            for value in values {
                if let _id = value["id"] as? Int {
                    self.owned_shops_ids.append(_id)
                }
            }
        }
       
    }
    
    func shopOwned(shop : Shop ) -> Bool {
        for shopId in self.owned_shops_ids {
            if shopId == shop.id {
                return true
            }
        }
        return false
    }
    func userShops() -> [String : String] {
        var  shops : [String : String] = [:]
        for shop in self.owned_shops_ids {
            shops["\(shop)"] = "\(shop)"
        }
        return shops
    }
    func bindShops(shops : [String : String]) {
        self.owned_shops_ids = []
        for shop_id in shops.keys {
            
            if let _id = Int(shop_id){
                self.owned_shops_ids.append(_id)
            }
        }
    }
}
