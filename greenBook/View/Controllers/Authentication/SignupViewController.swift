//
//  SignupViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/10/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: AbstractScrollableViewController {
    // MARK : Outlets
    @IBOutlet weak var inputFieldsView: UIView!
    @IBOutlet weak var prifoleImageView: UIImageView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordConfTF: UITextField!
    var user : User = User()
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTextField(textField: userNameTF)
        self.addTextField(textField: emailTF)
        self.addTextField(textField: passwordTF)
        self.addTextField(textField: passwordConfTF)
    }
    
    // MARK: User Actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func signupPressed(_ sender: UIButton) {
        self.signupUser()
    }
    @IBAction func uploadImagePressed(_ sender: UIButton) {
        uploadImage()
    }
    @IBAction func uploadImageTapped(_ sender: UITapGestureRecognizer) {
        uploadImage()
    }
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.dismissKeyboard()
    }
    
    // MARK : Actions
    
    func uploadImage() {
        DispatchQueue.main.async {
            self.openImagePicker()
        }

    }
    
    func signupUser() {
        if checkUserParams() {
            self.startLoading()
            UserManager().signupUser(user: self.user, handler: { (response) in
                self.endLoading()
                if response.status {
                    
                    if let newUser = response.result as? User {
                        UserSession.sharedInstant.currUser = newUser
                        UserSession.sharedInstant.token = newUser.token
                        _ = UserSession.sharedInstant.cacheUser()
                        
                        // TODO Perform segue
                        self.loginUser()
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
        }
    }
    
    func checkUserParams() -> Bool{
        if let username = userNameTF.text {
            if !username.validName() {
                self.showErrorMessage(errorMessage: "Invalid username")
                return false
            }
            user.name = username
        }else{
            self.showErrorMessage(errorMessage: "Something went wrong")
            return false
        }
        if let email = emailTF.text {
            if !email.validEmail() {
                self.showErrorMessage(errorMessage: "Invalid Email address")
                return false
            }
            user.email = email
        }else{
            self.showErrorMessage(errorMessage: "Something went wrong")
            return false
        }
        
        if let password = passwordTF.text {
            if !password.validPassword() {
                self.showErrorMessage(errorMessage: "Invalid Password, must be at least 6 characters")
                return false
            }
            user.password = password
        }else{
            self.showErrorMessage(errorMessage: "Something went wrong")
            return false
        }
        
        if let passwordConf = passwordConfTF.text {
            if passwordConf != user.password {
                self.showErrorMessage(errorMessage: "Password Mismatch")
                return false
            }
        }else{
            self.showErrorMessage(errorMessage: "Something went wrong")
            return false
        }
        
        return true
    }
    
    func loginUser() {
        performSegue(withIdentifier: "userLoggedIn", sender: self)
    }
    
    override func updateUI() {
        super.updateUI()
        if let url = URL.init(string: self.imageUrl){
            self.user.image_url = url.absoluteString
           self.prifoleImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icProfile"))
        }
    }
}
