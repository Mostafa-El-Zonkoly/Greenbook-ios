//
//  AddReviewViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/23/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

enum ReviewEditType {
    case add
    case edit
    case reply
}
protocol AddReviewDelegate {
    func setNewRate(rate : Double, count : Int)
}
class AddReviewViewController: AbstractViewController {
    var state : ReviewEditType = .add
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var shop : Shop?
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var reviewTextView: PlaceholderTextView!
    
    @IBOutlet weak var guideLabel: UILabel!
    
    var review : ShopReview = ShopReview()
    var delegate : AddReviewDelegate?
    var replyToReview : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeNavigationBar()
        
        if replyToReview {
            self.reviewTextView.placeholderText = "Write a Reply"
        }
        self.reviewTextView.text = self.reviewTextView.placeholderText
        bindUser()
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(gestureRecognizer)
        var title = "Add"
        if state == .edit {
            title = "Update"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: title, style: .done, target: self, action: #selector(saveReview))
        
        self.rateView.rating = 1.0
        self.rateView.isHidden = replyToReview
        self.guideLabel.isHidden = replyToReview
        if state == .edit {
            bindReview()
        }
    }
    func bindReview(){
        rateView.rating = Double(review.rate)
        reviewTextView.text = review.review
        reviewTextView.emptyText = false
    }
    @objc func saveReview(){
        print("Save Review")
        if let shop = self.shop {
        if reviewTextView.emptyText || reviewTextView.text.count == 0{
            self.showErrorMessage(errorMessage: "Can't Add empty review")
            return
        }
        self.review.review = reviewTextView.text
        self.review.rate = Int(self.rateView.rating)
        self.startLoading()
            if state == .reply {
                ReviewsManager().replyReview(review: review, message: reviewTextView.text, shop: self.shop!, handler: { (response) in
                    self.endLoading()
                    if response.status {
                        self.navigationController?.popViewController(animated: true)
                        return
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                })
            }else{
                ReviewsManager().addReview(review: review,update: (state == .edit), shop: shop, handler: { (response) in
                    self.endLoading()
                    if response.status{
                        if let dict = response.result as? [String : Any]{
                            if let rate = dict["shop_rate"] as? Double, let reviewsCount = dict["num_of_reviews"] as? Int {
                                self.delegate?.setNewRate(rate: rate, count: reviewsCount)
                            }
                        }
                       self.navigationController?.popViewController(animated: true)
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                })
            }
        }else{
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
        }
    }
    @objc func closeKeyboard(){
        self.reviewTextView.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindUser()
    }
    func bindUser(){
        let user = UserSession.sharedInstant.currUser
        if let url = URL.init(string: user.image_url) {
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icProfile"))
        }else{
            profileImageView.image = #imageLiteral(resourceName: "icProfile")
        }
        usernameLabel.text = user.name
    }
}
