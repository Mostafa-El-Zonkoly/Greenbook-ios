//
//  CircularView.swift
//  Shaifak
//
//  Created by Mostafa on 10/7/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class CircularLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        layer.cornerRadius = frame.size.height / 2;
        clipsToBounds = true;
        if self.tag != 1 {
            self.layer.borderColor = self.tintColor.cgColor
            self.layer.borderWidth = 1
        }
    }
}
