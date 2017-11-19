//
//  AbstractSegmentedBarViewController.swift
//  Shaifak
//
//  Created by Mostafa on 10/16/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Toast_Swift
import NVActivityIndicatorView
import SwiftMessages
class AbstractSegmentedBarViewController: BaseButtonBarPagerTabStripViewController<SegmentCollectionCell> {
    // variables
    var activityIndicator : NVActivityIndicatorView!
    let activityIndicatorSize = CGSize.init(width: 60, height: 60)

    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    // Set Status Bar Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    // MARK: Loading & Messages
    private func addActivityIndicator(){
        // Initialize Activity Indicator
        let viewFrame = self.view.bounds
        let frame = CGRect.init(origin: CGPoint.init(x: (viewFrame.width - activityIndicatorSize.width)/2.0, y: (viewFrame.height - activityIndicatorSize.height)/2.0), size: activityIndicatorSize)
        activityIndicator = NVActivityIndicatorView.init(frame: frame)
        activityIndicator.type = .ballClipRotateMultiple
        activityIndicator.color = UIColor.white
        activityIndicator.backgroundColor = UIColor.init(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 0.7)
        
        view.addSubview(activityIndicator)
    }
    
    // MARK: Show Annoncements to user
    
    // Announcements
    func showErrorMessage(errorMessage : String){
        // TODO Show error messages
        SwiftMessages.sharedInstance.defaultConfig.presentationStyle = .bottom
        let view = MessageView.viewFromNib(layout: .CardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        view.configureContent(title: errorMessage, body: "", iconText: "")
        view.button?.setTitle("", for: UIControlState.normal)
        view.button?.setImage(UIImage.init(), for: .normal)
        view.button?.isHidden = true
        view.contentMode = .center
        // Show the message.
        SwiftMessages.show(view: view)
    }
    
    func showMessage(message: String){
        // TODO Show success, etc. messages
        SwiftMessages.sharedInstance.defaultConfig.presentationStyle = .bottom
        let view = MessageView.viewFromNib(layout: .CardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        
        view.configureContent(title: message, body: "", iconText: "")
        view.button?.setTitle("", for: UIControlState.normal)
        view.button?.setImage(UIImage.init(), for: .normal)
        view.button?.isHidden = true
        view.frame.origin.x = 0
        view.frame.size.width = self.view.frame.width
        // Show the message.
        SwiftMessages.show(view: view)
        

    }
    
    func showGBError(error : GBError){
        self.showErrorMessage(errorMessage: error.description)
    }
    func showError(error : Error) {
        // TODO Show error
        self.showErrorMessage(errorMessage: error.localizedDescription)
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoading(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}
