//
//  SearchMapViewController.swift
//  greenBook
//
//  Created by Mostafa on 12/2/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import MapKit
class SearchMapViewController: AbstractViewController, GMSMapViewDelegate,ShopMarkerInfoViewDelegate {
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var googleMapContainer: UIView!
    var shops : [Shop] = []
    var startLocation : CLLocationCoordinate2D = AbstractManager.locationManager.location!.coordinate
    var delegate : SearchControllerProtocol?
    var googleMapView : GMSMapView!
    let userMarker = GMSMarker()
    var shopMarkers : [GMSMarker] = []
    
    @IBOutlet weak var redoButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    self.navigationController?.isNavigationBarHidden = false
        customizeNavigationBar()
        self.redoButton.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icSwitchSearch"), style: .done, target: self, action: #selector(backToInitial(_:)))
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icSwitchSearch"), style: .done, target: self, action: #selector(refineSearch(_:)))

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        self.navigationItem.title = "Maps"

        self.buttonsView.isHidden = true
    }
    
    @IBAction func refineSearchButtonPressed(_ sender: UIButton) {
        self.refineSearch(sender)
    }
    @objc func refineSearch(_ sender: AnyObject) {
        if let parent = self.delegate {
            self.redoButton.isHidden = true
            self.startLoading()
            userMarker.position = self.googleMapView.camera.target
            parent.searchInLocation(location: self.googleMapView.camera.target, handler: { (response) in
                self.endLoading()
                var newShops : [Shop] = []
                if response.status {
                    if let newResults = response.result as? [Shop] {
                        newShops = newResults
                    }
                }else{
                    if let error = response.error {
                        self.showGBError(error: error)
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                    }
                }
                
                self.shops = newShops
                self.showShops()
            })
        }
    }
    deinit {
        if let parent = self.delegate {
            parent.destroyCalls()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    // MARK : MAP Functions
    
    func initMap(){
        // Create a GMSCameraPosition that tells the map to display the
        view.layoutIfNeeded()
        googleMapContainer.layoutIfNeeded()
        print(googleMapContainer.frame)
        userMarker.position = startLocation
        let camera = GMSCameraPosition.camera(withLatitude: startLocation.latitude, longitude: startLocation.longitude, zoom: 6.0)
        
        if googleMapView == nil {
            googleMapView = GMSMapView.map(withFrame: googleMapContainer.bounds, camera: camera)
            googleMapContainer.addSubview(googleMapView)
            userMarker.tracksViewChanges = true
            userMarker.tracksInfoWindowChanges = true
            userMarker.map = googleMapView
            userMarker.tracksInfoWindowChanges = true
            userMarker.title = "Search Location"
            userMarker.icon = #imageLiteral(resourceName: "cirLocation")
            userMarker.iconView?.contentMode = .center
            userMarker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5) // For image to be centered
            
            googleMapView.isMyLocationEnabled = true
            googleMapView.settings.myLocationButton = true
            googleMapView.settings.compassButton = true
//            self.view.bringSubview(toFront: googleMapContainer)

        }
        googleMapView.frame = googleMapContainer.bounds
        googleMapView.camera = camera

        googleMapView.delegate = self
        self.googleMapContainer.bringSubview(toFront: self.redoButton)
        showShops()

    }
    
    
    func showShops(){
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(userMarker.position)
        var index  = 0
        for marker in shopMarkers {
            marker.map = nil
        }
        for shop in shops {
            let marker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: shop.location.lat, longitude: shop.location.long))
            marker.userData = index
            index = index + 1
            marker.title = shop.name
            marker.snippet = shop.phone_number
            self.shopMarkers.append(marker)
            marker.map = googleMapView
            marker.infoWindowAnchor = CGPoint.init(x: -5, y: 0)
            marker.isTappable = true
            marker.iconView?.clipsToBounds = false
            marker.iconView?.backgroundColor = UIColor.blue
            marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
            
            bounds = bounds.includingCoordinate(marker.position)
        }
        // To fit map to show all shops
        googleMapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50.0 , 50.0 ,50.0 ,50.0)))
    }
    
    var selectedMarker : GMSMarker? {
        didSet {
            if selectedMarker == nil {
                self.buttonsView.isHidden = true
                self.googleMapView.settings.myLocationButton = true
            }else{
                self.buttonsView.isHidden = false
                self.googleMapView.settings.myLocationButton = false
            }
        }
    }
    
    // MARK: Google maps delegate
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        selectedMarker = marker
        print("Select Marker")
        if marker == userMarker {
            return nil
        }
        if let index = marker.userData as? Int {
            if index < self.shops.count {
                let shop = self.shops[index]
                if let shopInfo = Bundle.main.loadNibNamed("ShopMarkerInfoView", owner: self, options: nil)?.first as? ShopMarkerInfoView{
                    shopInfo.delegate = self
                    shopInfo.bindShop(shop: shop)
                    shopInfo.isUserInteractionEnabled = true
                    return shopInfo
                }

            }
        }
        return nil
    }
    var selectedShop : Shop?
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let index = marker.userData as? Int {
            if index < self.shops.count {
                let shopToOpen : Shop = self.shops[index]
                self.selectedShop = shopToOpen
                self.performSegue(withIdentifier: "showShopSegue", sender: self)
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        selectedMarker = nil
        print("Deselect Marker")
    }
    
    func closeInfo() {
        googleMapView.selectedMarker = nil
    }
    let minDistance : Double = 100 // in meters
    var cameraTarget : GMSCameraPosition?
    var dragChange : Bool = false
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let oldTarget = cameraTarget, dragChange {
            let oldLocation  = CLLocation.init(latitude: oldTarget.target.latitude, longitude: oldTarget.target.longitude)
            let newLocation = CLLocation.init(latitude: position.target.latitude, longitude: position.target.longitude)
            let distance = oldLocation.distance(from: newLocation)
            if oldLocation.distance(from: newLocation) > minDistance {
                self.redoButton.isHidden = false
            }
        }else{
            print("Update Target")
            cameraTarget = position
        }
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("Will move with Gesture \(gesture)")
        dragChange = gesture
    }
    @IBAction func showDirection(_ sender: UIButton) {
        var coordinates = CLLocationCoordinate2D()
        var title = "Item"
        
        if let marker = self.selectedMarker {
            
            let latitude:CLLocationDegrees =  marker.position.latitude
            let longitude:CLLocationDegrees =  marker.position.longitude
            coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            if let value = marker.title {
                title = value
            }
        
            let regionDistance:CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                ] as [String : Any]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = title
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func showLocation(_ sender: Any) {
        
        var coordinates = CLLocationCoordinate2D()
        var title = "Item"
        if let marker = self.selectedMarker {
            
            let latitude:CLLocationDegrees =  marker.position.latitude
            let longitude:CLLocationDegrees =  marker.position.longitude
            
            coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            if let value = marker.title {
                title = value
            }
            let regionDistance:CLLocationDistance = 10000
            
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = title
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShopSegue"
        {
            if let dest = segue.destination as? ShopViewController {
                if let shop = self.selectedShop {
                    dest.shop = shop
                }

            }
        }
    }
    
}
