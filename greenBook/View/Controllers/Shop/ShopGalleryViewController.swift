//
//  ShopGalleryViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Kingfisher
import FTImageViewer

class ShopGalleryViewController: AbstractViewController,IndicatorInfoProvider {
    @IBOutlet weak var imageGridView: FTImageGridView!
    @IBOutlet weak var imageGridHeight: NSLayoutConstraint! // the height constrain for grid in stroyboard

    @IBOutlet weak var scrollView: UIScrollView!
    var shop : Shop!
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: "Gallery")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = self.scrollView.frame
        frame.size.width = self.view.frame.width
        self.scrollView.frame = frame
        var gridFrame = self.imageGridView.frame
        gridFrame.size.width = frame.size.width - 20
        self.imageGridView.frame = gridFrame
        self.scrollView.setNeedsDisplay()
        
      

    }
    var imagesArray : [String] = [] {
        didSet{
            imageGridHeight.constant = FTImageGridView.getHeightWithWidth(imageGridView.frame.width, imgCount: self.shop.photos.count)
            scrollView.contentSize.height = imageGridHeight.constant
            scrollView.contentSize.width = scrollView.frame.width

            self.view.setNeedsLayout()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var tempImages : [String] = []
        for photo in self.shop.photos {
            tempImages.append(photo.photo_url)
        }
        self.imagesArray = tempImages
        scrollView.contentSize.height = imageGridHeight.constant
        scrollView.contentSize.width = scrollView.frame.width
        
        imageGridView.showWithImageArray(self.imagesArray) { (buttonsArray, buttonIndex) in
            // preview images with one line of code
            
            FTImageViewer.showImages(self.imagesArray, atIndex: buttonIndex, fromSenderArray: buttonsArray)
        }
      
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
     
    }
    


    
    

}
