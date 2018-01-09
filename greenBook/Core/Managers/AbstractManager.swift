//
//  AbstractManager.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import Alamofire
import ReachabilitySwift
import CoreLocation
enum RestfulStatus {
    case not_found
    case success
    case unauthorized
    case validation_error
    case server_error
    case connection_error
    static func statusByCode(code :Int) -> RestfulStatus {
        
        if code == 200 {
            return .success
        }else if code == 401 {
            return .unauthorized
        }else if code == 422 {
            
            return .validation_error
        }else if code == 404 {
            return .not_found
            
        }else if code == 599{
            return .connection_error
        }else{
            return .server_error
        }
    }
}
class AbstractManager : NSObject{
    static let locationManager : CLLocationManager = CLLocationManager()
    
    func internetConnected() -> Bool {
        
        if let reachability = Reachability.init() {
            return reachability.isReachable
        }
        return false
    }
    
    func locationEnabled() -> Bool {
        let authorizationState =  CLLocationManager.authorizationStatus()
        if authorizationState == CLAuthorizationStatus.authorizedAlways || authorizationState == CLAuthorizationStatus.authorizedWhenInUse {
            AbstractManager.locationManager.startUpdatingLocation()
            return true
        }else{
            AbstractManager.locationManager.requestWhenInUseAuthorization()
        }
        return false
    }
    func canRequest() -> Bool {
        return internetConnected() && UserSession.sharedInstant.userLoggedIn()
    }
    
    func getHeader(auth : Bool) -> [String : Any] {
        if auth {
            return ["Authorization" : UserSession.sharedInstant.token]
        }else{
            return [:]
        }
    }
    
    func parseMeta(dict: [String : Any]) -> Response {
        let response = Response()
        response.error = GBError()
        if let meta = dict["meta"] as? [String: Any] {
            if let status = meta["status"] as? Int, let message = meta["message"] as? String {
                let userInfo: [String : Any] =
                    [
                        NSLocalizedDescriptionKey :  message ]
                let restfulStatus = RestfulStatus.statusByCode(code: status)
                switch restfulStatus {
                case .success:
                    response.error = nil
                    break
                case .connection_error:
                    response.error?.error_type = .connection
                    response.error?.error = NSError.init(domain: "GreenBook", code: status, userInfo: userInfo)
                    break
                case .not_found:
                    response.error?.error_type = .not_found
                    response.error?.error = NSError.init(domain: "GreenBook", code: status, userInfo: userInfo)
                    break
                case .unauthorized:
                    response.error?.error_type = .authentication
                    response.error?.error = NSError.init(domain: "GreenBook", code: status, userInfo: userInfo)

                    break
                case .validation_error:
                    response.error?.error_type = .invalid
                    response.error?.error = NSError.init(domain: "GreenBook", code: status, userInfo: userInfo)

                    break
                case .server_error:
                    response.error?.error_type = .server_error                   
                    let error = NSError.init(domain: "GreenBook", code: status, userInfo: userInfo)
                    response.error?.error = error
                    break
                }
            }
        }
        return response
    }
}
