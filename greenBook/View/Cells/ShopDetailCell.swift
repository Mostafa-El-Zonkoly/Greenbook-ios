//
//  ShopDetailCell.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class ShopDetailCell: UITableViewCell {
    var shop : Shop?
    var detailsType : ShopDetailsCellIDs = .address
    @IBOutlet weak var detailsLabel : UILabel!
    func bindShop(shop: Shop, detailsType : ShopDetailsCellIDs ){
        self.shop = shop
        self.detailsType = detailsType
        switch self.detailsType {
        case .address:
            self.detailsLabel.text = shop.location.address
            break
        case .hours:
            self.detailsLabel.text = shop.isOpenText()
            break
        case .phone:
            self.detailsLabel.text = shop.phone_number
            break
            
        }
    }
}
