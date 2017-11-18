//
//  BorderlessView.swift
//  Shaifak
//
//  Created by Mostafa on 10/7/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class BorderlessView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        
    }
}
