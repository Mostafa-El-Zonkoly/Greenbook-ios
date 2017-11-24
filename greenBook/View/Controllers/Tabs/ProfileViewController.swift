//
//  ProfileViewController.swift
//  greenBook
//
//  Created by Mostafa on 11/24/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit
enum ProfileCellTypes{
    case header
    case accountSeparator
    case edit
    case password
    case invite
    case logout
    case supportUS
    case rateApp
}
class ProfileViewController: AbstractViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var loggedInCellTypes : [ProfileCellTypes] = [.header, .accountSeparator, .edit, .password, .logout, .supportUS, .invite, .rateApp]
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < loggedInCellTypes.count {
            let cellType = loggedInCellTypes[indexPath.row]
            switch cellType {
            case .accountSeparator:
                return 31.0
            case .supportUS:
                return 51.0
            case .header:
               return 230.0
            default:
                return 62.0
            }
        }
        return 44.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loggedInCellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < loggedInCellTypes.count {
            let cellType = loggedInCellTypes[indexPath.row]
            switch cellType {
            case .accountSeparator:
                return tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
            case .supportUS:
                return tableView.dequeueReusableCell(withIdentifier: "SupportCell", for: indexPath)
            case .header:
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ProfileHeaderCell
                cell.bindUser(user: UserSession.sharedInstant.currUser)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! ProfileMenuCell
                cell.bindCell(type: cellType)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < loggedInCellTypes.count {
            let cellType = loggedInCellTypes[indexPath.row]
            switch cellType {
                case .edit:
                    self.editProfile()
                    break
                case .invite:
                    self.inviteFriend()
                    break
                case .rateApp:
                    self.rateApp()
                    break
                case .password:
                    self.changePassword()
                    break
                case .logout:
                    self.logout()
                    break
                default:
                    break
            }
        }
    }
    
    let appURL = "https://itunes.apple.com/us/app/id1185250904"

   
    func editProfile(){
        
    }
    
    func inviteFriend(){
        let textToShare = "Check out Greenbook iOS"
        
        if let myWebsite = URL(string:appURL) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true) {
            }
        }else{
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)

        }
    }
    func rateApp(){
        let str = appURL
        if let url = URL(string: str) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
    func logout(){
        UserSession.sharedInstant.logoutUser()
        self.navigationController?.tabBarController?.dismiss(animated: true, completion: nil)
    }
    func changePassword(){
        let alertController = UIAlertController(title: "Change your password", message: "Please enter your password", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction.init(title: "Save", style: .default, handler: { (alert) in
            if let textFields = alertController.textFields {
                if textFields.count >= 3 {
                    let oldPasswordTF = textFields[0]
                    let newPasswordTF = textFields[1]
                    let newPassConfirmationTF = textFields[2]
                    if let oldPass = oldPasswordTF.text, let newPass = newPasswordTF.text, let newPassConfirmation = newPassConfirmationTF.text {
                        if UserSession.sharedInstant.currUser.password == oldPass {
                            if newPass.characters.count >= 6 {
                                if newPass == newPassConfirmation {
                                    let user = UserSession.sharedInstant.currUser
                                    user.password = newPass
                                    self.startLoading()
                                    UserManager().updateUser(user: user, handler: { (response) in
                                        self.endLoading()
                                        if response.status {
                                            if let newUser = response.result as? User {
                                                UserSession.sharedInstant.currUser = newUser
                                            }
                                            UserSession.sharedInstant.password = user.password
                                            UserSession.sharedInstant.cacheUser()
                                            self.showMessage(message: "Password updated")
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
                                    self.showErrorMessage(errorMessage: "Password Mismatch")
                                    return
                                }
                            }else{
                                self.showErrorMessage(errorMessage: "Password too short")
                                return
                            }
                        }else{
                            self.showErrorMessage(errorMessage: "Invalid Password")
                            return
                        }
                    }
                    
                }
            }
            
            self.showErrorMessage(errorMessage: Messages.DEFAULT_ERROR_MSG)
        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        
        
        
        //Section 2
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Current Password"
            textField.textAlignment = .left
            textField.isSecureTextEntry = true
        })
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "New Password"
            textField.textAlignment = .left
            textField.isSecureTextEntry = true
        })
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "New Password Confirmation"
            textField.textAlignment = .left
            textField.isSecureTextEntry = true
        })

        self.present(alertController, animated: true, completion: nil)
    }
}
