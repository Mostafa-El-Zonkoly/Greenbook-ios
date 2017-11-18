//
//  ShopView.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ShopView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.tag != -1 {
            let view = Bundle.main.loadNibNamed("ShopView", owner: self, options: nil)!.first as! ShopView
            self.addSubview(view)
            view.frame = self.frame
        }
    }
}
