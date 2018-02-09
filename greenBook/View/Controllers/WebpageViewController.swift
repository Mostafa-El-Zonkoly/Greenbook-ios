//
//  WebpageViewController.swift
//  greenBook
//
//  Created by Mostafa on 2/9/18.
//  Copyright © 2018 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import WebKit
class WebpageViewController: AbstractViewController, UIWebViewDelegate {
    
    //    @IBOutlet weak var privacyWebView: WKWebView!
    
    @IBOutlet weak var privacyWebView: UIWebView!
    var urlString : String = ""
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        customizeNavigationBar()
        overrideBackButton()
        self.privacyWebView.delegate = self
        if let url = URL.init(string: urlString){
            let req = URLRequest.init(url: url)
            self.startLoading()
            self.privacyWebView!.loadRequest(req)

        }else{
            self.showErrorMessage(errorMessage: "Couldn't Find Page")
        }
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.endLoading()
    }
    
}

