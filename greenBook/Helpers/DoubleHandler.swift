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
        return String.localizedStringWithFormat("%.\(decimals)f", self)
    }
}
