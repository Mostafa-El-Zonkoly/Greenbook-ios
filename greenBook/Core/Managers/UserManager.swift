//
//  UserManager.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import Alamofire
class UserManager : AbstractManager {
    
    func signupUser(user: User, handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.SIGNUP_URL) {
            
            let headers = getHeader(auth: false) as! HTTPHeaders
            let params : [String : Any] = ["data":["user" : user.toDict()]]
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

                        
                        if let _ = dict["data"] as? NSDictionary, let userDict = (dict["data"] as! [String: Any])["user"] as? [String : Any] {
                            // Success
                            let user = User()
                            user.bindDictionary(dict: userDict)
                            response.result = user
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
    
    func updateUser(user: User, handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.SIGNUP_URL) {
            
            let headers = getHeader(auth: true) as! HTTPHeaders
            let params : [String : Any] = ["data":["user" : user.toDict()]]
            Alamofire.request(url, method: HTTPMethod.put, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
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
                        
                        
                        if let _ = dict["data"] as? NSDictionary, let userDict = (dict["data"] as! [String: Any])["user"] as? [String : Any] {
                            // Success
                            if user.password != UserSession.sharedInstant.password {
                                UserSession.sharedInstant.password = user.password
                                UserSession.sharedInstant.currUser.password = user.password
                            }
                            let newUser = User()
                            newUser.bindDictionary(dict: userDict)
                            newUser.password = user.password
                            response.result = newUser
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
    func signInUser(user: User,handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.LOGIN_URL) {
            
            let headers = getHeader(auth: false) as! HTTPHeaders
            let params : [String : Any] = ["data":user.toDict()]
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
                        
                        
                        if let _ = dict["data"] as? NSDictionary, let userDict = (dict["data"] as! [String: Any])["user"] as? [String : Any] {
                            // Success
                            let user = User()
                            user.bindDictionary(dict: userDict)
                            response.result = user
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
    
    func forgetPassword(email: String,handler: @escaping (Response) -> Void) {
        // First check connectivity
        var response = Response()
        if !self.internetConnected() {
            response.error = GBError()
            response.error?.error_type = .connection
            handler(response)
            return
        }
        if let url = URL.init(string: URLS.FORGET_PASSWORD_URL) {
            
            let headers = getHeader(auth: false) as! HTTPHeaders
            let params : [String : Any] = ["data": email]
            Alamofire.request(url, method: HTTPMethod.post, parameters: params, headers: headers).responseJSON(completionHandler: { (serverResponse) in
                if let error = serverResponse.error {
                    response.error = GBError()
                    response.error?.error_type = .server_error
                    response.error?.error = error
                    handler(response)
                    return
                }else {
                    // TODO Parse User Returned
                    if let dict = serverResponse.result as? [String : Any] {
                        response = self.parseMeta(dict: dict as! [String : Any])
                        if !response.status {
                            handler(response)
                            return
                        }
                        
                        
                        response.error = nil
                        handler(response)
                        return
                        
                        
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
