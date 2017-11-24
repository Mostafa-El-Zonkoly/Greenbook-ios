
//
//  UserSession.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation


class UserSession {
    let userKey = "user"
    let tokenKey = "token"
    static let sharedInstant = UserSession()
    var currUser : User = User()
    var token : String = ""
    var password : String = ""
    func userLoggedIn () -> Bool {
        return currUser.saved && token.count > 0
    }
    
    func cacheUser() -> Bool{
        let userDefaults = UserDefaults.standard
        currUser.password = password
        userDefaults.setValue(currUser.toDict(), forKey: userKey)
        userDefaults.setValue(token, forKey: tokenKey)
        return userDefaults.synchronize()
    }
    
    func loadUser() {
        let userDefaults = UserDefaults.standard
        
        if let userDict = userDefaults.value(forKey: userKey) as? [String : Any] {
            self.currUser.bindDictionary(dict: userDict)
        }else{
            self.currUser.bindDictionary(dict: [:])
        }
        
        if let value = userDefaults.value(forKey: tokenKey) as? String {
            self.token = value
            self.currUser.token = value
        }
        
    }
    
    func logoutUser(){
        self.currUser = User()
        self.token = ""
        let userDefualts = UserDefaults.standard
        userDefualts.removeObject(forKey: userKey)
        userDefualts.removeObject(forKey: tokenKey)
        userDefualts.synchronize()
    }
}
