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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
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
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
       let detailsView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopDetailsView") as! DetailsViewController
        if let shop = self.shop {
            detailsView.shop = shop
        }
        let shopGalleryView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopGalleryView") as! ShopGalleryViewController
        if let shop = self.shop {
            shopGalleryView.shop = shop
        }
        
        let shopReviewView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShopReviewView") as! ShopReviewsViewController
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
        self.navigationController?.isNavigationBarHidden = false
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
        self.performSegue(withIdentifier: "addReviewSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReviewSegue", let dest = segue.destination as? AddReviewViewController {
            // TODO Set Shop
            dest.delegate = self
            dest.shop = self.shop
        }
    }
    
    func setNewRate(rate: Double, count: Int) {
        self.shop?.rate = rate
        self.shop?.num_of_reviews = count
        if let shop = self.shop {
            self.shopView.bindShop(shop: shop)
        }
    }
    
}
