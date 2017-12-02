//
//  ShopMarkerInfoView.swift
//  greenBook
//
//  Created by Mostafa on 12/2/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
protocol ShopMarkerInfoViewDelegate {
    func closeInfo()
}

class ShopMarkerInfoView: UIView {
    
    @IBOutlet weak var shopNameLabel: UILabel!
    var delegate : ShopMarkerInfoViewDelegate?
    var shop : Shop = Shop()
    @IBOutlet weak var shopImageView: CircularImage!
    
    @IBOutlet weak var shopRateLabel: UILabel!
    
    @IBOutlet weak var shopRateView: CosmosView!
    
    @IBAction func dismissMarkerInfo(_ sender: UIButton) {
        self.delegate?.closeInfo()
    }
    
    func bindShop(shop : Shop){
        self.shop = shop
        if let url = URL.init(string: shop.main_photo_url) {
            self.shopImageView.sd_setImage(with: url)
        }else{
            self.shopImageView.image = nil
        }
        self.shopRateView.rating = shop.rate
        self.shopRateLabel.text = "\(shop.rate.toString(decimals: 1)))"
        self.shopNameLabel.text = shop.name
    }
}
