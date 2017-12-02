//
//  CategoryManager.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import Alamofire
import ReachabilitySwift
import CoreLocation

class CategoryManager: AbstractManager {
    static let sharedInistance : CategoryManager = CategoryManager()
    var categories : [Category] = []
    
    func loadCategories(handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.CATEGORIES_URL) {
            
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
                        
                        
                        if let _ = dict["data"] as? NSDictionary, let categoriesDict = (dict["data"] as! [String: Any])["categories"] as? [[String : Any]] {
                            // Success
                            var categories : [Category] = []
                            for categoryDict in categoriesDict {
                                let category = Category.init()
                                category.bindDictionary(dict: categoryDict)
                                categories.append(category)
                            }
                            self.categories = categories
                            response.result = categories
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
    
    /*
         Return Filtered Categories
     */
    func getCategoriesWithPrefix(prefix : String) -> [Category] {
        var filtered : [Category] = []
        if prefix.count > 0 {
            for category in self.categories {
                if category.name.lowercased().contains(prefix.lowercased()) {
                    filtered.append(category)
                }
            }
        }
        return filtered
    }
    
    func loadCategoryShops(category : Category, lat: Double, long : Double, handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if !self.locationEnabled() {
            response.error = GBError()
            response.error?.error_type = .location_service
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.SEARCH_URL) {
            
            let headers = getHeader(auth: false) as! HTTPHeaders
            let params : [String : Any] = ["category_id" : category.id, "lat" : lat, "lng" : long]
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
                            var shops : [Shop] = []
                            for shopDict in shopsDict {
                                let shop = Shop()
                                shop.bindDictionary(dict: shopDict)
                                shops.append(shop)
                            }
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
}

