//
//  ProfileHeaderCell.swift
//  greenBook
//
//  Created by Mostafa on 11/24/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class ProfileHeaderCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    func bindUser(user : User){
        if let url = URL.init(string: user.image_url) {
            self.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icProfile-1"))
        }else{
            self.profileImageView.image = #imageLiteral(resourceName: "icProfile-1")
        }
        self.emailLabel.text = user.email
        self.userName.text = user.name
    }
}
