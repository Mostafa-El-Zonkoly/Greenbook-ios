//
//  GBError.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

enum ERROR_TYPE {
    case connection
    case authentication
    case invalid
    case server_error
    case not_found
    case location_service
    
}
class GBError : NSObject {
    
    var error : Error?
    var error_type : ERROR_TYPE = .server_error
    
    override var description: String {
        if let err = error {
            return err.localizedDescription
        }else{
            switch error_type {
            case .authentication:
                return "Unauthorized"
            case .invalid:
                return "Invalid Parameters"
            case .connection:
                return "No Internet Connection, please check your internet connection"
            case .not_found:
                return "Not found"
            case .location_service:
                return "Please enable location service"
            case .server_error:
                    return "Something went wrong"
            }
        }
    }
    
}
