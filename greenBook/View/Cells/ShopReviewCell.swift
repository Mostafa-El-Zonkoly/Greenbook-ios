//
//  ShopReviewCell.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import SDWebImage
class ShopReviewCell: UITableViewCell {
    
    var shopReview : ShopReview?
    
    @IBOutlet weak var reviewMessageLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var reviewRate: CosmosView!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var reviewerImageView: CircularImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    func bindReview(review : ShopReview){
        self.shopReview = review
        self.reviewMessageLabel.text = review.review
        self.rateLabel.text = "\(review.rate)"
        self.reviewRate.rating = Double(review.rate)
        self.reviewDateLabel.text = review.getDateFormatted()
        if let imgURL = URL.init(string: review.user.image_url) {
            self.reviewerImageView.sd_setImage(with: imgURL, placeholderImage: #imageLiteral(resourceName: "icProfile"))
        }else{
            self.reviewerImageView.image = #imageLiteral(resourceName: "icProfile")
        }
        self.reviewerNameLabel.text = review.user.name
    }
}

