//
//  FavouriteShopsViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/23/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class FavouriteShopsViewController: AbstractViewController, UITableViewDelegate, UITableViewDataSource, ShopViewDelegate {
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var shops :[Shop] = [] {
        didSet{
                dataExists()
        }
    }
    func dataExists(){
        if shops.count == 0 {
            // Show no Data
            self.noDataView.isHidden = false
            self.view.bringSubview(toFront: self.noDataView)
        }else{
            self.noDataView.isHidden = true
            self.view.sendSubview(toBack: self.noDataView)
        }
    }
    var selectedShop : Shop?
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControlEvents.allEvents)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLoading()
        self.reloadData()
    }
    
    // MARK: Table view datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as? ShopCell {
            if indexPath.row < self.shops.count {
                let shop = self.shops[indexPath.row]
                cell.shopDelegate = self
                cell.bindShop(shop: shop, distanceHidden: true)
                return cell
            }
        }
        return UITableViewCell.init()
    }
    // MARK : Tableview delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  indexPath.row < self.shops.count {
            self.selectedShop = self.shops[indexPath.row]
            performSegue(withIdentifier: "showShopSegue", sender: self)
            
        }
    }
    
    // MARK: Shop Detail Cell
    func toggleFavState(shop: Shop) {
        let fav = !shop.favourited()
        self.startLoading()
        ShopManager.sharedInstance.favouriteShopState(shop: shop, state: fav) { (response) in
            
            self.endLoading()
            if response.status {
                self.reloadData()
            }else{
                self.tableView.reloadData()
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showShopSegue" {
            if let dest = segue.destination as? ShopViewController {
                if let shop = self.selectedShop {
                    dest.shop = shop
                }
            }
        }
    }
    
    @objc func reloadData(){
        ShopManager.sharedInstance.loadFavouriteShops { (response) in
            var favShops : [Shop] = []
            if let favShopsDict = response.result as? [Int : Shop] {
                for shopID in favShopsDict.keys {
                    if let shop = favShopsDict[shopID]{
                        favShops.append(shop)
                    }
                }
            }
            self.shops = favShops
            self.endLoading()
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

}
