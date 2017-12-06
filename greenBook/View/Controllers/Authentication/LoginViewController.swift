//
//  LoginViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/5/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
class LoginViewController: AbstractFormViewController, GIDSignInDelegate,GIDSignInUIDelegate {
    
    
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
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserSession.sharedInstant.loadUser()
        if UserSession.sharedInstant.userLoggedIn() {
            self.proceedLoginUser()
        }
        GIDSignIn.sharedInstance().uiDelegate = self


    }
    // MARK: User Actions Handler
    
    @IBAction func loginFacebook(_ sender: UITapGestureRecognizer) {
        let loginManager = LoginManager()
        self.startLoading()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self) { (loginResult) in
            
            switch loginResult {
            case .failed(let error):
                self.showError(error: error)
                self.endLoading()
                break
            case .cancelled:
                print("Cancelled")
                self.endLoading()
                break
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in!")
                    let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name,picture.type(large)"], accessToken: accessToken, httpMethod: GraphRequestHTTPMethod.GET,apiVersion: GraphAPIVersion.defaultVersion)
                    req.start({ (response, requestResult) in
                        switch requestResult {
                        case .failed(let error):
                            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                            self.endLoading()
                            break
                        case .success(let graphResponse):
                            if let responseDictionary = graphResponse.dictionaryValue {
                                print(responseDictionary)
                                
                                var dict: NSDictionary!
                                var name = ""
                                var email = ""
                                var image = ""
                                if let value = responseDictionary["email"] as? String {
                                    email = value
                                }
                                if let value = responseDictionary["name"] as? String {
                                    name = value
                                }
                                if let valueDict = responseDictionary["picture"] as? [String : Any] {
                                    if let pictureDict = valueDict["data"] as? [String : Any] {
                                        if let value = pictureDict["url"] as? String{
                                            image = value
                                        }
                                    }
                                }
                                UserManager().socialLogin(accountType: "facebook", accountID: accessToken.userId!, accountToken: accessToken.authenticationToken, image_url: image, name: name, email: email, handler: { (managerResponse) in
                                    self.endLoading()
                                    if managerResponse.status {
                                        if let newUser = managerResponse.result as? User {
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
                                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                                        self.endLoading()
                                    }
                                })
                                
                                
                            }else{
                                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                                self.endLoading()
                            }
                        }

                    })
                    
                
            }
        }
    }
    @IBAction func loginGoogle(_ sender: UITapGestureRecognizer) {
        self.startLoading()
        GIDSignIn.sharedInstance().signIn()
        
        
    }
    // MARK: Google Plus Delegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor _user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            self.endLoading()
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
        }else{
            if let user = _user {
                var accountID = ""
                var accountToken = ""
                var imageURL = ""
                var name = ""
                var email = ""
                if let value = user.userID {
                    accountID = value
                }
                if let value = user.authentication.accessToken {
                    accountToken = value
                }
                if let value = user.profile.name {
                    name = value
                }
                if let value = user.profile.email {
                    email = value
                }
                if let value = user.profile.imageURL(withDimension: 40) {
                    imageURL = value.absoluteString
                }
            UserManager().socialLogin(accountType: "google", accountID: accountID, accountToken: accountToken, image_url: imageURL, name: name, email: email, handler: { (response) in
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
            }else{
                self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                self.endLoading()
            }
            
        }
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
