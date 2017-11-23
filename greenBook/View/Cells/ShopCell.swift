


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
    var shopViewAdded = false
    @IBOutlet weak var containerView: UIView!
    var shopView : ShopView!
    // MARK: Outlets
    override func awakeFromNib() {
        super.awakeFromNib()
        addShopView()
        self.containerView.layoutSubviews()
    }
    var shopDelegate : ShopViewDelegate?
    var delegate : ShopCellDelegate?
    var shop : Shop?
    
    func bindShop (shop: Shop , distanceHidden : Bool){
        self.selectionStyle = .none
        self.shopView.bindShop(shop: shop, distanceHidden : distanceHidden)
       self.shopView.delegate = self.shopDelegate
    }
    func addShopView(){
        if let _shopView = Bundle.main.loadNibNamed("ShopView", owner: self, options: nil)?.first as? ShopView{
            shopViewAdded = true
            self.shopView = _shopView
            self.containerView.addSubview(shopView)
            
            let horizontalConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
            containerView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint,leading,trailing])
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.shopView.resetView()
    }
}

