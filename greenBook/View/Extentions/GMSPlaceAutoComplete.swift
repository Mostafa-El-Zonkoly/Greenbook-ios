//
//  GMSPlaceAutoComplete.swift
//  greenBook
//
//  Created by Mostafa on 12/2/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        
        self.location = place.coordinate
        self.locationTF.text = place.formattedAddress
        if let _ = self.selectedCategory{
            self.loadData(showLoading: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.locationTF.text = ""
//        if let loc = AbstractManager.locationManager.location?.coordinate {
            self.location = nil
//        }
        
        if let _ = self.selectedCategory {
            self.loadData(showLoading: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
