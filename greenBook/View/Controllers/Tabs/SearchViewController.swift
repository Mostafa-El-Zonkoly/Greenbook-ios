//
//  SearchViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

enum SearchState {
    case noSearch
    case noResults
    case results
    case searching
}

enum SearchType {
    case category
    case location
}
class SearchViewController: AbstractViewController, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate,ShopViewDelegate {
    var searchType : SearchType = .location
    var selectedShop : Shop?
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    // MARK: Outlets
    @IBOutlet weak var categorySearchView: RoundedView!
    
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var locationMapImgView: UIImageView!
    @IBOutlet weak var locationTF: UITextField!
    var categories : [Category] = []
    var filteredCategories : [Category] = []
    var shops : [Shop] = []
    var selectedCategory : Category?
    var viewState : SearchState = .noSearch {
        didSet{
            self.adjustView()
        }
    }
    func searchViewHeight() -> CGFloat{
        switch self.viewState {
        case .noSearch:
            return 80
        default:
            return 120
        }
    }
    func adjustView(){
        // Todo Adjust Search State Depending on Search State
        self.searchViewHeightConstraint.constant = searchViewHeight()
        self.categorySearchView.isHidden = self.viewState == .noSearch
        switch self.viewState {
        case .results:
            self.locationMapImgView.isHidden = false
            break
        default:
            self.locationMapImgView.isHidden = true
        }
        self.view.layoutIfNeeded()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.viewState = .noSearch
        
        // Capture location On map action
        let gestureRecong = UITapGestureRecognizer.init(target: self, action: #selector(showOnMap))
        self.locationMapImgView.isUserInteractionEnabled = true
        self.locationMapImgView.addGestureRecognizer(gestureRecong)
        CategoryManager.sharedInistance.loadCategories { (response) in
            self.categories = CategoryManager.sharedInistance.categories
            self.tableView.reloadData()
        }
        self.navigationController?.isNavigationBarHidden = true
        self.filterTable.rowHeight = 40.0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedShop = nil
        self.navigationController?.isNavigationBarHidden = true

        ShopManager.sharedInstance.loadFavouriteShops { (response) in
            self.tableView.reloadData()
        }
    }
    override func viewDidLayoutSubviews() {
        
    }
    
    // MARK: Textfield Delegate
    
    
    // MARK: Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(self.tableView) {

            if self.viewState == .noSearch {
                return self.categories.count
            }else if self.viewState == .results {
                return self.shops.count
            }
        }else{
            if self.searchType == .category {
                return self.filteredCategories.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(self.tableView) {

            if self.viewState == .noSearch {
                if indexPath.row < self.categories.count {
                    let category = self.categories[indexPath.row]
                    let cell = UITableViewCell.init()
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.text = category.name
                    cell.separatorInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
                    cell.selectionStyle = .none
                    return cell
                }
            }else if self.viewState == .results {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell", for: indexPath) as? ShopCell {
                    if indexPath.row < self.shops.count {
                        let shop = self.shops[indexPath.row]
                        cell.shopDelegate = self
                        cell.bindShop(shop: shop, distanceHidden: false)
                        
                        return cell
                    }
                }
            }
        }else{
            if self.searchType == .category {
                if indexPath.row < self.filteredCategories.count {
                    let category = self.filteredCategories[indexPath.row]
                    let cell = UITableViewCell.init()
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.text = category.name
                    cell.separatorInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEqual(self.tableView) {
            if self.viewState == .noSearch {
                if indexPath.row < self.categories.count {
                    let category = self.categories[indexPath.row]
                    self.searchTF.text = category.name
                    self.selectedCategory = category
                    self.viewState = .searching
                    self.loadData()
                }
            }else{
                // Result is of a shop
                if  indexPath.row < self.shops.count {
                    self.selectedShop = self.shops[indexPath.row]
                    performSegue(withIdentifier: "showShopSegue", sender: self)

                }
            }
        }else{
            if self.searchType == .category {
                if indexPath.row < self.filteredCategories.count {
                    let category = self.filteredCategories[indexPath.row]
                    self.searchTF.text = category.name
                    self.selectedCategory = category
                    self.viewState = .searching
                    self.filterCategories(prefix: "")
                    self.loadData()
                }
            }
        }
    }
    
    // MARK: User Actions
    @objc func showOnMap(){
        
    }
    
    func loadData(){
        // TODO Load Data related to category
        self.searchTF.resignFirstResponder()
        self.locationTF.resignFirstResponder()
        if let category = self.selectedCategory {
            self.startLoading()
            CategoryManager.sharedInistance.loadCategoryShops(category: category, lat: 0, long: 0, handler: { (response) in
                self.endLoading()
                if response.status {
                    if let newShops = response.result as? [Shop] {
                        self.shops = newShops
                        if self.shops.count > 0 {
                            self.viewState = .results
                        }else{
                            self.viewState = .noResults
                        }
                        self.tableView.reloadData()
                    }
                }else if let error = response.error {
                    self.showGBError(error: error)
                    
                }else{
                    self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                }
            })
        }else{
            self.shops = []
            self.viewState = .noResults
            self.tableView.reloadData()
        }
    }
    
    // MARK : textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            if textField.isEqual(self.searchTF) {
                self.filterCategories(prefix: txtAfterUpdate)
            }
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(searchTF){
            self.searchType = .category
        }else{
            self.searchType = .location
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.selectedCategory = nil
        if textField.isEqual(self.searchTF){
            for category in self.categories {
                if category.name == textField.text! {
                    self.selectedCategory = category
                    break
                }
            }
        }
        self.filterCategories(prefix: "")
        self.loadData()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.searchTF){
            if let prefix = self.searchTF.text {
                self.filterCategories(prefix: prefix)
            }
        }
        return true
    }
    func filterCategories(prefix : String){
        self.filteredCategories =  CategoryManager.sharedInistance.getCategoriesWithPrefix(prefix: prefix)
        self.filterViewHeightConstraint.constant = CGFloat(self.filteredCategories.count) * self.filterTable.rowHeight
        self.filterTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShopSegue" {
            if let dest = segue.destination as? ShopViewController {
                if let shop = self.selectedShop {
                    dest.shop = shop
                }
            }
        }
    }
    
    func toggleFavState(shop: Shop) {
        let fav = !shop.favourited()
        self.startLoading()
        ShopManager.sharedInstance.favouriteShopState(shop: shop, state: fav) { (response) in
            self.tableView.reloadData()
            self.endLoading()
            if response.status {
                
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
            }
        }
    }
}
