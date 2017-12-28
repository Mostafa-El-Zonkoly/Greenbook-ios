//
//  DetailsViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/18/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

enum ShopDetailsCellIDs {
    case address
    case hours
    case phone
    
    func cellID() -> String{
        switch self {
        case .address:
            return "AddressCell"
        case .hours:
            return "HoursCell"
        case .phone:
            return "PhoneCell"
        }
    }
}

class DetailsViewController: AbstractViewController,IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    var shop : Shop!
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: "Details")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTableView.rowHeight = UITableViewAutomaticDimension
    }
    func reloadData(){
        detailsTableView.reloadData()
    }
    
    // MARK: Tableview datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    let cellIdentifiers : [ShopDetailsCellIDs] = [.hours,.phone]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < cellIdentifiers.count, let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.section].cellID(), for: indexPath) as? ShopDetailCell {
            cell.bindShop(shop: self.shop, detailsType: cellIdentifiers[indexPath.section])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < cellIdentifiers.count, cellIdentifiers[indexPath.section] == .phone{
            if let url = URL(string: "tel://\(self.shop.phone_number)") {
                UIApplication.shared.open(url, options: [:], completionHandler: { (result) in
                    if !result {
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                })
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
            }

        }
    }
    
}

