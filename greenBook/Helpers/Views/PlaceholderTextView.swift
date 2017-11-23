//
//  PlaceholderTextView.swift
//  greenBook
//
//  Created by Mostafa on 11/23/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit


class PlaceholderTextView: UITextView, UITextViewDelegate {
    var placeholderText : String = "Placeholder text"
    var placeholderColor : UIColor = UIColor.init(red: 178.0/255.0, green: 178.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    var defaultTextColor : UIColor = UIColor.init(red: 178.0/255.0, green: 178.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    var emptyText : Bool = true {
        didSet{
            if self.emptyText {
                self.textColor = placeholderColor
                self.text = placeholderText
            }else{
                self.textColor = defaultTextColor
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.emptyText = true
        self.defaultTextColor = UIColor.black
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if emptyText {
            self.text = ""
            self.emptyText = false
            self.textColor = defaultTextColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.text.characters.count == 0 {
            self.emptyText = true
        }
    }
}
