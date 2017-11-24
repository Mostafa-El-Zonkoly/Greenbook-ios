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
    @IBAction func forgetPassword(_ sender: UIButton) {
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
