//
//  DoubleHandler.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

extension Double {
    func toString(decimals: Int) -> String{
        var min : Double = 0.9
        for _ in 1...decimals {
            min = min / 10.0
        }
        if self < min {
            return "0"
        }
        
        return String.localizedStringWithFormat("%.\(decimals)f", self)
    }
}
