//
//  AbstractViewController.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SwiftMessages

class AbstractViewController : UIViewController {
    
    // variables
    var activityIndicator : NVActivityIndicatorView!
    let activityIndicatorSize = CGSize.init(width: 60, height: 60)
    // MARK: Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
    }
    
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
