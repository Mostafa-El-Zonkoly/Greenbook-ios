//
//  SearchViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GooglePlaces

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


protocol SearchControllerProtocol {
    func searchInLocation(location : CLLocationCoordinate2D, handler: @escaping (Response) -> Void)
    func destroyCalls()
}
class SearchViewController: AbstractViewController, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate,ShopViewDelegate, SearchControllerProtocol {
    var searchType : SearchType = .location
    var selectedShop : Shop?
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    // MARK: Outlets
    @IBOutlet weak var categorySearchView: RoundedView!
    var location : CLLocationCoordinate2D?
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var noResultScreen: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var locationMapImgView: UIImageView!
    @IBOutlet weak var locationTF: UITextField!
    var categories : [Category] = []
    var filteredCategories : [Category] = []
    var shops : [Shop] = []
    var selectedCategory : Category?
    
    var loadOnAppear = false
    // MARK: Google Places Search
    let autocompleteController = GMSAutocompleteViewController()

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
    
    func showScreen(type : ScreenType){
        switch type {
        case .none:
            self.noResultScreen.isHidden = true
            break
        case .hint:
            self.noResultScreen.isHidden = false
            self.noResultLabel.text = "Pull down or\n type keyword to search."
            break
        case .noResult:
            self.noResultScreen.isHidden = false
            self.noResultLabel.text = "No Shops found."
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Capture location On map action
        let gestureRecong = UITapGestureRecognizer.init(target: self, action: #selector(showOnMap))
        self.locationMapImgView.isUserInteractionEnabled = true
        self.locationMapImgView.addGestureRecognizer(gestureRecong)
        self.startLoading()
        CategoryManager.sharedInistance.loadCategories { (response) in
            self.endLoading()
            self.categories = CategoryManager.sharedInistance.categories
            self.tableView.reloadData()
        }
        self.navigationController?.isNavigationBarHidden = true
        self.filterTable.rowHeight = 40.0
        
        if AbstractManager().locationEnabled() {
            if let _ = AbstractManager.locationManager.location {
//                self.location = loc.coordinate
            }
        }
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.noResultLabel.text = "Pull down or type keyword to search."
        self.view.sendSubview(toBack: self.noResultScreen)
        self.adjustView()
        
    }
    @objc func didPullToRefresh() {
        self.loadData(showLoading: false)
    }
    
    @objc func applicationWillEnterForeground() {
        if loadOnAppear {
            self.loadData(showLoading: true)
        }
    }
    func getLocation() -> CLLocationCoordinate2D {
        if let searchLocation = self.location {
            return searchLocation
        }else{
            if AbstractManager().locationEnabled() {
                if let loc = AbstractManager.locationManager.location {
                    return loc.coordinate
                }
            }
        }
        return CLLocationCoordinate2D.init()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        self.selectedShop = nil
        self.navigationController?.isNavigationBarHidden = true
        if self.viewState != .noSearch {
            if loadOnAppear {
                self.loadData(showLoading: true)
            }else{
                showScreen(type: .hint)
            }
            loadOnAppear = true
        }else{
            self.showScreen(type: .none)
        }
        ShopManager.sharedInstance.loadFavouriteShops { (response) in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
//            if self.searchType == .category {
//                return self.filteredCategories.count
//            }
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
                    self.loadData(showLoading: true)
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
                    self.loadData(showLoading: true)
                }
            }
        }
    }
    
    // MARK: User Actions
    @objc func showOnMap(){
        self.performSegue(withIdentifier: "showMapSegue", sender: self)
    }
    
    func loadData(showLoading : Bool){
        // TODO Load Data related to category
        self.searchTF.resignFirstResponder()
        self.locationTF.resignFirstResponder()
        if showLoading {
            self.startLoading()
        }
        if let text = self.searchTF.text {
            self.query = text
        }
        let loc = self.getLocation()
            CategoryManager.sharedInistance.loadCategoryShops(query: self.query, lat: loc.latitude, long: loc.longitude, handler: { (response) in
                self.endLoading()
                self.refreshControl.endRefreshing()
                if let compHandler = self.completionHandler {
                    compHandler(response)
                    self.completionHandler = nil
                }
                if response.status {
                    if let newShops = response.result as? [Shop] {
                        self.shops = newShops
                        if self.shops.count > 0 {
                            self.viewState = .results
                            self.showScreen(type: .none)
                        }else{
                            self.viewState = .noResults
                            self.showScreen(type: .noResult)
                        }
                        self.tableView.reloadData()
                    }
                }else if let error = response.error {
                    self.showGBError(error: error)
                    
                }else{
                    self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                }
            })
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
    var query = ""
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(searchTF){
            self.searchType = .category
        }else{
            self.searchType = .location
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
            textField.inputView = nil

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
        self.loadData(showLoading: true)
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
        self.query = prefix
//        self.filteredCategories =  CategoryManager.sharedInistance.getCategoriesWithPrefix(prefix: prefix)
//        self.filterViewHeightConstraint.constant = CGFloat(self.filteredCategories.count) * self.filterTable.rowHeight
//        self.filterTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShopSegue" {
            if let dest = segue.destination as? ShopViewController {
                if let shop = self.selectedShop {
                    dest.shop = shop
                    dest.keepNavBar = false
                }
            }
        }else if segue.identifier == "showMapSegue" {
            if let mapView = segue.destination as? SearchMapViewController {
                mapView.startLocation = self.getLocation()
                mapView.delegate = self
                mapView.shops = self.shops
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    var completionHandler: ((Response)->Void)?
    func searchInLocation(location: CLLocationCoordinate2D, handler: @escaping (Response) -> Void) {
        self.location = location
        self.locationTF.text = "Current Map Area"
        self.completionHandler = handler
        self.loadData(showLoading: false)
    }
    func destroyCalls() {
        self.completionHandler = nil
    }
}
