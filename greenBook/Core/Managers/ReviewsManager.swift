//
//  ReviewsManager.swift
//  greenBook
//
//  Created by Mostafa on 11/23/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import ReachabilitySwift
import Alamofire


class ReviewsManager: AbstractManager {
    
    
    func addReview (review : ShopReview, shop: Shop, handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: String.init(format: URLS.ADD_REVIEW_URL, shop.id)) {
            
            let headers = getHeader(auth: true) as! HTTPHeaders
            let params : [String : Any] = ["data" : review.toSeverDict()]
            Alamofire.request(url, method: HTTPMethod.post, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
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
                        if let data = dict["data"] as? [String: Any], let _ = (dict["data"] as! [String: Any])["shop_rate"] as? Double, let _ = (dict["data"] as! [String: Any])["num_of_reviews"] as? Int {
                            // Success
                            
                            response.result = data
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
    
    
}
