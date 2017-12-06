//
//  LoginViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/5/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: AbstractFormViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTextField(textField: emailTF)
        self.addTextField(textField: passwordTF)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.loginViewController = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserSession.sharedInstant.loadUser()
        if UserSession.sharedInstant.userLoggedIn() {
            self.proceedLoginUser()
        }
    }
    // MARK: User Actions Handler
    
    @IBAction func loginFacebook(_ sender: UITapGestureRecognizer) {
        self.showMessage(message: "Login Facebook")
    }
    @IBAction func loginGoogle(_ sender: UITapGestureRecognizer) {
        self.showMessage(message: "Login Google")
    }
    @IBAction func loginEmail(_ sender: UIButton) {
        self.loginUser()
    }
    
    @IBAction func signup(_ sender: UIButton) {
//        self.showMessage(message: "Signup")
    }
    
    func signupUser(){
        self.performSegue(withIdentifier: "signupUser", sender: self)
    }
    
    @IBAction func forgetPassword(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Forget password", message: "Please enter your email", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction.init(title: "Reset", style: .default, handler: { (alert) in
            if let textFields = alertController.textFields {
                if textFields.count >= 1 {
                    let emailAddreessTF = textFields[0]
                    if let email = emailAddreessTF.text, emailAddreessTF.text!.validEmail() {
                        self.startLoading()
                        UserManager().forgetPassword(email: email, handler: { (response) in
                            self.endLoading()
                            if response.status {
                                let alertController = UIAlertController(title: "Password Reset", message: "Password reset instruction sent to your email", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction.init(title: "OK", style: .default , handler: { (alert) in
                                    
                                }))
                                self.present(alertController, animated: true, completion: nil)
                                return

                            }else{
                                if let error = response.error {
                                    self.showGBError(error: error)
                                }else{
                                    self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                                }
                            }
                        })
                        return
                    }else{
                        self.showErrorMessage(errorMessage: "Invalid email Address")
                    }
                    
                }
            }
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        
        
        
        //Section 2
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Email Address"
            textField.textAlignment = .left
            textField.isSecureTextEntry = false
            textField.keyboardType = UIKeyboardType.emailAddress
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboardPressed(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    
    // MARK: Logic
    
    func loginUser() {
        if let email = emailTF.text {
            if !email.validEmail() {
                self.showErrorMessage(errorMessage: "Invalid Email")
                return
            }
            if let password = passwordTF.text {
                if !password.validPassword() {
                    self.showErrorMessage(errorMessage: "Invalid Password")
                    return
                }
                let user = User()
                user.email = email
                user.password = password
                self.startLoading()
                UserSession.sharedInstant.password = password
                UserManager().signInUser(user: user, handler: { (response) in
                    self.endLoading()
                    if response.status {
                        if let newUser = response.result as? User {
                            UserSession.sharedInstant.currUser = newUser
                            UserSession.sharedInstant.token = newUser.token
                            _ = UserSession.sharedInstant.cacheUser()
                            
                            // TODO Perform segue
                            self.proceedLoginUser()
                            self.showMessage(message: "User logged in")
                        }else{
                            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                        }
                    }else{
                        if let error = response.error {
                            self.showGBError(error: error)
                        }else{
                            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                        }
                    }
                    
                })
                return
            }
        }
        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
    }
    @IBOutlet weak var skipLogin: UIButton!
    
    @IBAction func skipLoginPressed(_ sender: UIButton) {
        self.proceedLoginUser()
    }
    func proceedLoginUser() {
        self.performSegue(withIdentifier: "userLoggedIn", sender: self)
    }
    
}
