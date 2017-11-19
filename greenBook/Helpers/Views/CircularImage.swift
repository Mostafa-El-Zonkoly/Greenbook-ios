//
//  CircularImage.swift
//  Shaifak
//
//  Created by Mostafa on 10/7/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class CircularImage : UIImageView{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        layer.cornerRadius = frame.size.height / 2;
        clipsToBounds = true;
        if self.tag != 1 {
            self.layer.borderColor = self.tintColor.cgColor
            self.layer.borderWidth = 2
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2;
        clipsToBounds = true;
        if self.tag != 1 {
            self.layer.borderColor = self.tintColor.cgColor
            self.layer.borderWidth = 2
        }

    }
    override func draw(_ rect: CGRect) {
        
        layer.cornerRadius = frame.size.height / 2;
        clipsToBounds = true;
        if self.tag != 1 {
            self.layer.borderColor = self.tintColor.cgColor
            self.layer.borderWidth = 2
        }
        super.draw(rect)
    }
}
