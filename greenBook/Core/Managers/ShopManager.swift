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
    var favouriteShops : [Int: Shop] = [:]
    
    func loadCachedFavourite() {
        if !UserSession.sharedInstant.userLoggedIn(){
            let userDefaults = UserDefaults.standard
            if let dict = userDefaults.value(forKey: "FavouriteCache") as? [Int : Shop] {
                self.favouriteShops = dict
            }
            self.cacheFavourite()
        }
    }
    func cacheFavourite(){
        if !UserSession.sharedInstant.userLoggedIn() {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(self.favouriteShops, forKey: "FavouriteCache")
            userDefaults.synchronize()
        }
    }
    func loadFavouriteShops(handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        loadCachedFavourite()
        
        
        if !UserSession.sharedInstant.userLoggedIn(){
            response.result = self.favouriteShops
            handler(response)
            return
        }
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.FAV_URL) {
            
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
                        if let _ = dict["data"] as? NSDictionary, let shopsDict = (dict["data"] as! [String: Any])["favourites"] as? [[String : Any]] {
                            // Success
                            var shops : [Int : Shop] = [:]
                            for shopDict in shopsDict {
                                let shop = Shop()
                                shop.bindDictionary(dict: shopDict)
                                shops[shop.id] = shop
                            }
                            
                            self.favouriteShops = shops
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
                                reviews.append(review)
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
