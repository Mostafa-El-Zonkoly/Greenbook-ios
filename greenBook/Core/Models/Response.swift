//
//  Response.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation


class Response {
    var error : GBError? {
        didSet {
            self.status = (error == nil)
        }
    }
    var status : Bool = true
    var result : Any?
}
