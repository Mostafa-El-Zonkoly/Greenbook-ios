//
//  ViewController.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import UIKit

class ViewController: AbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserSession.sharedInstant.loadUser()
        if UserSession.sharedInstant.userLoggedIn() {
            self.showMessage(message: UserSession.sharedInstant.currUser.name)
        }
    }

    @IBAction func doAction(_ sender: UIButton) {
        let user = User()
        user.name = "Test Signup Logic"
        user.image_url = "http://www.google.com/images/1.png"
        user.password = "12345678"
        user.email = "2_endpoint@ios.com"
        self.startLoading()
        UserManager().signInUser(user: user) { (response) in
            self.endLoading()
            if response.status {
                if let currUser = response.result as? User{
                    print(currUser.toDict())
                    UserSession.sharedInstant.currUser = currUser
                    UserSession.sharedInstant.token = currUser.token
                    print(UserSession.sharedInstant.cacheUser())
                    
                    self.showMessage(message: "User \(currUser.name) logged in")
                }else{
                    self.showErrorMessage(errorMessage: "Something went wrong")
                }
            }else{
                if let error = response.error {
                    self.showGBError(error: error)
                }
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

