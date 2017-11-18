//
//  ShopCell.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import SDWebImage
protocol ShopCellDelegate {
    func setFavouriteState(shop : Shop)
}

class ShopCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var shopImgView: UIImageView!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var favouriteImgView: UIImageView!
    @IBOutlet weak var shopDetailsLabel: UILabel!
    @IBOutlet weak var shopDistanceLabel: UILabel!
    
    @IBOutlet weak var shopTitleLabel: UILabel!
    var delegate : ShopCellDelegate?
    var shop : Shop?
    
    func bindShop(shop : Shop){
        self.selectionStyle = .none
        self.shop = shop
        self.shopDetailsLabel.text = shop.shopDescription
        self.shopTitleLabel.text = shop.name
        self.rateLabel.text = "\(shop.rate.toString(decimals: 1))  (\(shop.num_of_reviews))"
        self.rateView.rating = shop.rate
        if let url = URL.init(string: shop.main_photo_url) {
            self.shopImgView.sd_setImage(with: url)
        }
        if !shop.favourited() {
            self.favouriteImgView.image = #imageLiteral(resourceName: "icFav")
        }else{
            self.favouriteImgView.image = #imageLiteral(resourceName: "icFavSelected")
        }
        self.shopDistanceLabel.text = shop.getDistance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.shopImgView.image = nil
        self.shopTitleLabel.text = ""
        self.shopDetailsLabel.text = ""
        self.rateView.rating = 0
        self.rateLabel.text = "0.0  (0)"
        self.shopDistanceLabel.text = ""
    }
}
