//
//  RoundedButton.swift
//  Badeeb
//
//  Created by Mostafa on 10/3/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = self.tintColor.cgColor
    }
}

