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
protocol ShopReviewDelegate {
    func writeReviewPressed()
    func deleteReview(review : ShopReview)
    func editReview(review : ShopReview)
}
class ShopReviewsViewController: AbstractViewController,IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var addReviwButton: UIButton!
    
    @IBAction func writeReviewPressed(_ sender: UIButton) {
        self.delegate?.writeReviewPressed()
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Reviews"
    }
    let refreshControl = UIRefreshControl()
    var delegate : ShopReviewDelegate?
    @IBOutlet weak var tableView: UITableView!
    var reviews : [ShopReview] = [] {
        didSet{
            self.toggleAddReview()
        }
    }
    
    func toggleAddReview(){
        var addedReview = false
        for review in reviews {
            if review.user.id == UserSession.sharedInstant.currUser.id {
                addedReview = true
                break
            }
        }
        self.addReviwButton.isHidden = addedReview
    }
    var shop : Shop!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ShopReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "ReviewCell")
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.allEvents)
        self.tableView.refreshControl = self.refreshControl
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(gestureRecognizer)

    }
    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoading()
        self.reloadData()
    }
    @objc func reloadData(){
        ShopManager.sharedInstance.loadShopReviews(shop: self.shop) { (response) in
            self.endLoading()
            self.refreshControl.endRefreshing()
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
                cell.delegate = self.delegate
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
        if section == 0 {
            headerView.backgroundColor = UIColor.clear
        }else{
            headerView.backgroundColor = Colors.SEPARATOR_COLOR
        }
        return headerView
    }
    
}
