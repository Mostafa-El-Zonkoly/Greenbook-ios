//
//  ViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/18/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    // Set Navigation Bar
    func customizeNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = Colors.NAVIGATION_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [.font : Fonts.NavigationTitleFont, .foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    func overrideBackButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon_back_white"), style: .done, target: self, action: #selector(backToInitial(_:)))
    }
    @objc func backToInitial(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
