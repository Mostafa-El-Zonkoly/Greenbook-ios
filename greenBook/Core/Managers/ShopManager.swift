//
//  ShopManager.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import Alamofire
import ReachabilitySwift
import CoreLocation

class ShopManager: AbstractManager {
    static let sharedInstance : ShopManager = ShopManager()
    var favouriteShops : [Int: Int] = [:]
    
    func loadCachedFavourite() {
        if !UserSession.sharedInstant.userLoggedIn(){
            let userDefaults = UserDefaults.standard
            var newFav : [Int : Int] = [:]
            if let dict = userDefaults.value(forKey: "FavouriteCache") as? [String : String] {
                for key in dict.keys {
                    if let intKey = Int(key) {
                        newFav[intKey] = intKey
                    }
                }
            }
            self.favouriteShops = newFav
            self.cacheFavourite()
        }
    }
    func shopsDictionary() -> [String : String] {
        var dict : [String : String] = [:]
        for key in favouriteShops.keys {
            dict["\(key)"] = "\(key)"
        }
        return dict
    }
    func cacheFavourite(){
        if !UserSession.sharedInstant.userLoggedIn() {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(shopsDictionary(), forKey: "FavouriteCache")
            userDefaults.synchronize()
        }
    }
    
    func loadShopsWithIDs(shopIDs : [Int],handler: @escaping (Response) -> Void) {
    
    }
    func loadFavouriteShops(handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        loadCachedFavourite()
        
        var urlString = URLS.FAV_URL
        
        var ids = ""
        if !UserSession.sharedInstant.userLoggedIn(){
            urlString = URLS.SHOPS_WITH_IDS_URL
            for key in self.favouriteShops.keys {
                ids = "\(key),\(ids)"
            }
            if ids.count > 0 {
                ids = "\(ids)A"
                ids = ids.replacingOccurrences(of: ",A", with: "")
            }
        }
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: urlString) {
            
            let headers = getHeader(auth: true) as! HTTPHeaders
            let params : [String : Any] = ["ids":ids]
            Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
                if let error = serverResponse.error {
                    response.error = GBError()
                    response.error?.error_type = .server_error
                    response.error?.error = error
                    handler(response)
                    return
                }else {
                    // TODO Parse User Returned
                    if let dict = serverResponse.result.value as? NSDictionary {
                        response = self.parseMeta(dict: dict as! [String : Any])
                        if !response.status {
                            
                            handler(response)
                            return
                        }
                        if let _ = dict["data"] as? NSDictionary, let shopsDict = (dict["data"] as! [String: Any])["shops"] as? [[String : Any]] {
                            // Success
                            var shops : [Int : Shop] = [:]
                            var favShops : [Int : Int] = [:]
                            for shopDict in shopsDict {
                                let shop = Shop()
                                shop.bindDictionary(dict: shopDict)
                                shops[shop.id] = shop
                                favShops[shop.id] = shop.id
                            }
                            
                            self.favouriteShops = favShops
                            response.result = shops
                            handler(response)
                            return
                        }else{
                            response.error = GBError()
                            response.error?.error_type = .server_error
                            handler(response)
                            return
                        }
                        
                        
                    }else{
                        response.error = GBError()
                        response.error?.error_type = .server_error
                        handler(response)
                        return
                        
                    }
                }
            })
        }else{
            response.error = GBError()
            response.error?.error_type = .server_error
            handler(response)
        }
    }
    
    func loadShopReviews(shop: Shop, handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: String.init(format: URLS.SHOP_REVIEWS_URL, shop.id)) {
            
            let headers = getHeader(auth: true) as! HTTPHeaders
            let params : [String : Any] = [:]
            Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
                if let error = serverResponse.error {
                    response.error = GBError()
                    response.error?.error_type = .server_error
                    response.error?.error = error
                    handler(response)
                    return
                }else {
                    // TODO Parse User Returned
                    if let dict = serverResponse.result.value as? NSDictionary {
                        response = self.parseMeta(dict: dict as! [String : Any])
                        if !response.status {
                            
                            handler(response)
                            return
                        }
                        if let _ = dict["data"] as? NSDictionary, let shopsDict = (dict["data"] as! [String: Any])["reviews"] as? [[String : Any]] {
                            // Success
                            var reviews : [ShopReview] = []
                            for shopDict in shopsDict {
                                let review = ShopReview()
                                review.bindDictionary(dict: shopDict)
                                if review.user.id == UserSession.sharedInstant.currUser.id {
                                    reviews.insert(review, at: 0)
                                }else{
                                    reviews.append(review)
                                }
                            }
                            
                            response.result = reviews
                            response.status = true
                            handler(response)
                            return
                        }else{
                            response.error = GBError()
                            response.error?.error_type = .server_error
                            handler(response)
                            return
                        }
                        
                        
                    }else{
                        response.error = GBError()
                        response.error?.error_type = .server_error
                        handler(response)
                        return
                        
                    }
                }
            })
        }else{
            response.error = GBError()
            response.error?.error_type = .server_error
            handler(response)
        }
    }
    
    
    func favouriteShopState(shop: Shop, state: Bool, handler: @escaping (Response) -> Void) {
        if !UserSession.sharedInstant.userLoggedIn(){
            if state {
                favouriteShops[shop.id] = shop.id
                
            }else{
                favouriteShops.removeValue(forKey: shop.id)
            }
            cacheFavourite()
            let response = Response.init()
            response.error = nil
            response.status = true
            handler(response)
            return
        }
        
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        
        let url = URL.init(string: String.init(format: URLS.FAV_STATE_URL, shop.id))
        let httpMethod : HTTPMethod = (state) ? .post:.delete
        
        let headers = getHeader(auth: true) as! HTTPHeaders
        let params : [String : Any] = [:]
        Alamofire.request(url!, method: httpMethod, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
            if let error = serverResponse.error {
                response.error = GBError()
                response.error?.error_type = .server_error
                response.error?.error = error
                handler(response)
                return
            }else {
                // TODO Parse User Returned
                if let dict = serverResponse.result.value as? NSDictionary {
                    response = self.parseMeta(dict: dict as! [String : Any])
                    if !response.status {
                        handler(response)
                        return
                    }
                    self.loadFavouriteShops(handler: { (favShopResponse) in
                        handler(response)
                    })
                    
                    return
                    
                }else{
                    response.error = GBError()
                    response.error?.error_type = .server_error
                    handler(response)
                    return
                    
                }
            }
        })
    }
}
