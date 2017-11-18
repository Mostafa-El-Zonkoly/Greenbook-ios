//
//  RoundedView.swift
//  Shaifak
//
//  Created by Mostafa on 10/4/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class RoundedView : BorderedView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
    }
}
