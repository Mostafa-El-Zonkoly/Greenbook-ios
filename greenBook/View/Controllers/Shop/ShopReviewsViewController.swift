//
//  ShopReviewsViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class ShopReviewsViewController: AbstractViewController,IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Reviews"
    }
    
    @IBOutlet weak var tableView: UITableView!
    var reviews : [ShopReview] = []
    var shop : Shop!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ShopReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "ReviewCell")

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoading()
        ShopManager.sharedInstance.loadShopReviews(shop: self.shop) { (response) in
            self.endLoading()
            if response.status {
                var tmpReviews : [ShopReview] = []
                if let results = response.result as? [ShopReview] {
                    tmpReviews = results
                }
                self.reviews = tmpReviews
                self.tableView.reloadData()
            }else{
                if let gbError = response.error {
                    self.showGBError(error: gbError)
                }else{
                    self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < reviews.count {
            let review = reviews[indexPath.section]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ShopReviewCell {
                cell.bindReview(review: review)
                return cell
            }
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = Colors.SEPARATOR_COLOR
        return headerView
    }
}
