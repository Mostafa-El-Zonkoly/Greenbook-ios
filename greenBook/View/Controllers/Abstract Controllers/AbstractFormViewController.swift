//
//  AbstractFormViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/9/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class AbstractFormViewController: AbstractViewController, UITextFieldDelegate {
    var activeTextField : UITextField?
    var textFields : [UITextField] = []
    func addTextField(textField: UITextField) {
        if let prevTextField = textFields.last {
            prevTextField.returnKeyType = .next
        }
        textField.delegate = self
        textFields.append(textField)
    }
    
    // MARK: Text Field Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var index = 0
        activeTextField = nil
        for tf in textFields {
            if tf.isEqual(textField), textField.returnKeyType == .next , textFields.count > (index + 1){
                textFields[index + 1].becomeFirstResponder()
                return true
            }
            index = index + 1
        }
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        if let activeTF = activeTextField {
            activeTF.resignFirstResponder()
        }
    }
}
