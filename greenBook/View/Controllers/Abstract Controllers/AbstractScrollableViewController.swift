//
//  AbstractScrollableViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/10/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class AbstractScrollableViewController: AbstractFormViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var keyboardVisible = false
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isUserInteractionEnabled = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        dismissKeyboard()
    }
    var keyboardHeight : CGFloat = 0
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            keyboardVisible = true
            scrollToActiveField()
            
        }
    }
    
    
    func scrollToActiveField(){
        if let textField = activeTextField {
            let absoluteFrame = textField.convert(textField.frame, to: nil)
            let screenHeight = UIScreen.main.bounds.height
            let max_y = screenHeight - keyboardHeight
            var currentY = scrollView.contentOffset.y
            let delta = absoluteFrame.maxY - max_y
            if delta > 0 {
                currentY = currentY + delta
                scrollView.setContentOffset(CGPoint.init(x: 0, y: currentY), animated: true)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        activeTextField = nil
        keyboardVisible = false
    }
    
    // MARK: UITexfield delegate
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO
        super.textFieldDidBeginEditing(textField)
        if keyboardVisible {
            scrollToActiveField()
        }
    }
}
