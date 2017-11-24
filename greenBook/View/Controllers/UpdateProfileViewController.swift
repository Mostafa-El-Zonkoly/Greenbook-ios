//
//  UpdateProfileViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/24/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class UpdateProfileViewController: AbstractViewController {
    var user : User = User()
    @IBOutlet weak var profileImageView: CircularImage!
    
    @IBOutlet weak var fullNameTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveUser))
        self.fullNameTF.text = self.user.name
        if let url = URL.init(string: self.user.image_url){
            self.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icProfile-1"))
        }else{
            self.profileImageView.image = #imageLiteral(resourceName: "icProfile-1")
        }

    }
    
    @objc func saveUser(){
        if let fullName = fullNameTF.text, fullNameTF.text!.count > 0 {
            let userToSave = self.user
            userToSave.name = fullName
            self.startLoading()
            UserManager().updateUser(user: user, handler: { (response) in
                self.endLoading()
                if response.status {
                    if let newUser = response.result as? User {
                        UserSession.sharedInstant.currUser = newUser
                    }
                    UserSession.sharedInstant.password = userToSave.password
                    _ = UserSession.sharedInstant.cacheUser()
                    self.navigationController?.popViewController(animated: true)
                }else{
                    if let error = response.error {
                        self.showGBError(error: error)
                        return
                    }else{
                        self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
                        return
                    }
                }
            })
            return
        }else{
            self.showErrorMessage(errorMessage: "Name is required")
        }

    }
    func pickImage(){
        DispatchQueue.main.async {
            self.openImagePicker()
        }
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        self.pickImage()
    }
    
    @IBAction func uploadImagePressed(_ sender: UITapGestureRecognizer) {
        self.pickImage()
    }
    
    @IBAction func dismissKeyboardPressed(_ sender: UITapGestureRecognizer) {
        self.fullNameTF.resignFirstResponder()
    }
    
    override func updateUI() {
        super.updateUI()
        if let url = URL.init(string: self.imageUrl){
            self.user.image_url = url.absoluteString
            self.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icProfile"))
        }

    }
}
