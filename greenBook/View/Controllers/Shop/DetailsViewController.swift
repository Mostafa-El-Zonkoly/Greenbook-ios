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
    case website
    func cellID() -> String{
        switch self {
        case .address:
            return "AddressCell"
        case .hours:
            return "HoursCell"
        case .phone:
            return "PhoneCell"
        case .website:
            return "WebsiteCell"
        }
    }
}

class DetailsViewController: AbstractViewController,IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    var shop : Shop!
    
    @IBOutlet weak var detailsTableView: UITableView!
    var superViewController : UIViewController?
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
        return 3
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
    let cellIdentifiers : [ShopDetailsCellIDs] = [.hours,.phone, .website]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < cellIdentifiers.count, let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.section].cellID(), for: indexPath) as? ShopDetailCell {
            cell.bindShop(shop: self.shop, detailsType: cellIdentifiers[indexPath.section])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < cellIdentifiers.count, cellIdentifiers[indexPath.section] == .phone{
            var phoneNumber = self.shop.phone_number.replacingOccurrences(of: "(", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            
            if let url = URL(string: "tel://\(phoneNumber)") {
                UIApplication.shared.open(url, options: [:], completionHandler: { (result) in
                    if !result {
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                })
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
            }

        }else if indexPath.section < cellIdentifiers.count, cellIdentifiers[indexPath.section] == .hours {
            if let cell = tableView.cellForRow(at: indexPath) as? ShopDetailCell {
                cell.didSelectCell()
            }
        }else if indexPath.section < cellIdentifiers.count, cellIdentifiers[indexPath.section] == .website{
            // TODO open website
            if let _ = URL.init(string: self.shop.website), let parent = self.superViewController as? ShopViewController{
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                if let webpageController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebPageViewController") as? WebpageViewController{
                    webpageController.urlString = self.shop.website
                    webpageController.title = self.shop.name
                    parent.forwardSegue = true
                    parent.navigationController?.show(webpageController, sender: self)
                }
            }else{
                self.showErrorMessage(errorMessage: "Can't open url")
            }

        }
    }
    
}

