//
//  StringCheckers.swift
//  greenBook
//
//  Created by Mostafa on 11/9/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

extension String {
    func validEmail() -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func validPassword() -> Bool {
        return self.count >= 6
    }
    func validName() -> Bool {
        return self.count >= 6
    }
}
