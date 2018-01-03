//
//  ShopViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/18/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class ShopViewController: AbstractSegmentedBarViewController,ShopViewDelegate,ShopReviewDelegate, AddReviewDelegate {
    
    @IBOutlet weak var buttonsView: ButtonBarView!
    
    @IBOutlet weak var shopContainerView : UIView!
    var shopView : ShopView!
    var shop : Shop?
    var shopViewAdded = false
    let redColor = UIColor(red: 221/255.0, green: 0/255.0, blue: 19/255.0, alpha: 1.0)
    let unselectedIconColor = UIColor(red: 73/255.0, green: 8/255.0, blue: 10/255.0, alpha: 1.0)
    var keepNavBar = true
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    var forwardSegue = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "SegmentCollectionCell", bundle: Bundle(for: SegmentCollectionCell.self), width: { _ in
            return 45.0
        })
    }
    
    override func viewDidLoad() {
        // change selected bar color
        self.buttonBarView = buttonsView
        self.view.layoutSubviews()
        settings.style.buttonBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = Colors.SELECTED_SEGMENT_TEXT_COLOR
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: SegmentCollectionCell?, newCell: SegmentCollectionCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            print(self?.unselectedIconColor.description)
            guard changeCurrentIndex == true else { return }
            oldCell?.titleLabel.textColor = Colors.IDLE_SEGMENT_TEXT_COLOR
            newCell?.titleLabel.textColor = Colors.SELECTED_SEGMENT_TEXT_COLOR
        }
        
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        customizeNavigationBar()
        overrideBackButton()
        loadShop()

    }
    override func configure(cell: UICollectionViewCell, for indicatorInfo: IndicatorInfo) {
        if let segmentCell = cell as? SegmentCollectionCell {
            segmentCell.titleLabel.text = indicatorInfo.title
        }
    }
    @IBOutlet weak var shopContainerHeight: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !shopViewAdded {
            addShopView()
        }
        forwardSegue = false
        self.selectedReview = nil
        replyToReview = false
        shopContainerView.backgroundColor = UIColor.red
        bindShopView()
        self.navigationController?.isNavigationBarHidden = false
    }
    func bindShopView() {
        if let _shop = self.shop {
            shopView.bindShop(shop: _shop)
        }else{
            self.shopView.resetView()
        }
        self.containerView.layoutSubviews()
        self.shopContainerHeight.constant = self.shopView.frame.height
        self.view.layoutSubviews()
    }
    
    func loadShop(){
        if let shop = self.shop {
            ShopManager.sharedInstance.loadShopDetails(shop: shop, handler: { (response) in
                if response.status{
                    if let newShop = response.result as? Shop {
                        self.shop = newShop
                        self.shopReviewView.shop = newShop
                        self.shopGalleryView.shop = newShop
                        self.detailsView.shop = newShop
                        DispatchQueue.main.async {
                            if self.shopViewAdded {
                                self.bindShopView()
                            }
                            self.shopGalleryView.reloadData()
                            self.detailsView.reloadData()
                        }

                    }
                }
            })
        }
    }
    func addShopView(){
        if let _shopView = Bundle.main.loadNibNamed("ShopView", owner: self, options: nil)?.first as? ShopView{
            shopViewAdded = true
            self.shopView = _shopView
            self.shopContainerView.addSubview(shopView)
            
            let horizontalConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: shopContainerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: shopContainerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: shopContainerView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: shopView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: shopContainerView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
            shopContainerView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            shopContainerView.layoutSubviews()
            var frame = self.shopView.frame
            frame.size.width = shopContainerView.bounds.width
            self.shopView.frame = frame
            self.shopView.delegate = self
            
        }
        
    }
    let detailsView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsView") as! DetailsViewController
    let shopGalleryView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopGalleryView") as! ShopGalleryViewController
    let shopReviewView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopReviewView") as! ShopReviewsViewController

    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        if let shop = self.shop {
            detailsView.shop = shop
        }
        if let shop = self.shop {
            shopGalleryView.shop = shop
        }
        
        if let shop = self.shop {
            shopReviewView.shop = shop
        }
        shopReviewView.delegate = self

        var frame = detailsView.view.frame
        frame.size.width = self.containerView.frame.width
        detailsView.view.frame = frame
        shopGalleryView.view.frame = frame
        return [detailsView,shopGalleryView,shopReviewView]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !keepNavBar, !forwardSegue{
            self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
    func toggleFavState(shop: Shop) {
        let fav = !shop.favourited()
        self.startLoading()
        ShopManager.sharedInstance.favouriteShopState(shop: shop, state: fav) { (response) in
            if let shop = self.shop {
                self.shopView.bindShop(shop: shop)
            }
            self.endLoading()
            if response.status {
                
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
            }
        }
    }
    
    func writeReviewPressed() {
        if UserSession.sharedInstant.userLoggedIn() {
            forwardSegue = true
            self.performSegue(withIdentifier: "addReviewSegue", sender: self)
        }else{
            // TODO show popup
            let alertView = UIAlertController(title: "Please Login", message: "You have to login first to be able to add a review", preferredStyle: .alert)
            let registerAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                self.navigationController?.tabBarController?.dismiss(animated: true, completion: nil)
            })
            let backAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
                
            })
            alertView.addAction(backAction)
            alertView.addAction(registerAction)

            self.present(alertView, animated: true, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReviewSegue", let dest = segue.destination as? AddReviewViewController {
            // TODO Set Shop
            dest.delegate = self
            dest.shop = self.shop
            if let review = self.selectedReview {
                dest.review = review
                dest.state = .edit
                if replyToReview {
                    dest.replyToReview = true
                    dest.state = .reply
                }
            }
            
        }
    }
    
    func setNewRate(rate: Double, count: Int) {
        self.shop?.rate = rate
        self.shop?.num_of_reviews = count
        if let shop = self.shop {
            self.shopView.bindShop(shop: shop)
        }
    }
    
    var selectedReview : ShopReview?
    
    func editReview(review: ShopReview) {
        forwardSegue = true
        self.selectedReview = review
        self.performSegue(withIdentifier: "addReviewSegue", sender: self)
    }
    
    func deleteReview(review: ShopReview) {
        self.selectedReview = review
        let alertView = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete your shop review?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            self.startLoading()
            ReviewsManager().deleteReview(review: self.selectedReview!, shop: self.shop!, handler: { (response) in
                self.endLoading()
                if response.status {
                    self.showMessage(message: "Review Deleted")
                    self.selectedReview = nil
                    for controller in self.viewControllers {
                        if let reviews = controller as? ShopReviewsViewController {
                            reviews.startLoading()
                            reviews.reloadData()
                        }
                    }
                    if let dict = response.result as? [String : Any]{
                        if let rate = dict["shop_rate"] as? Double, let reviewsCount = dict["num_of_reviews"] as? Int {
                            self.setNewRate(rate: rate, count: reviewsCount)
                        }
                    }
                }else{
                    if let error = response.error {
                        self.showGBError(error: error)
                     
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                }
            })
        })
        alertView.addAction(OKAction)
        let editAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (alert) in
            
        })
        alertView.addAction(editAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !keepNavBar, !forwardSegue{
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    var replyToReview = false
    func replyReviewPressed(review: ShopReview) {
        selectedReview = review
        replyToReview = true
        forwardSegue = true
        self.performSegue(withIdentifier: "addReviewSegue", sender: self)
    }
}
