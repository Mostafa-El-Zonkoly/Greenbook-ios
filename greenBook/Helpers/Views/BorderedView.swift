//
//  BorderedView.swift
//  Shaifak
//
//  Created by Mostafa on 10/6/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class BorderedView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.cgColor

    }
}
