//
//  ShopDetailCell.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import DropDown

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
        case .website:
            self.detailsLabel.text = shop.website
            break
            
        }
    }
    let dropDown = DropDown()

    func didSelectCell(){
        if detailsType == .hours {
            
            DispatchQueue.main.async {
                
                // The view to which the drop down will appear on
                self.dropDown.anchorView = self.detailsLabel // UIView or UIBarButtonItem
                
                // The list of items to display. Can be changed dynamically
                if let hours = self.shop?.getHours() {
                    if hours.count > 0 {
                        self.dropDown.dataSource = hours
                        self.dropDown.show()
                    }
                }

            }
        }
    }
}
