//
//  ProfileMenuCell.swift
//  greenBook
//
//  Created by Mostafa on 11/24/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

class ProfileMenuCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindCell(type : ProfileCellTypes){
        switch type {
        case .accountSeparator,.header,.supportUS:
            self.titleLabel.text = ""
            break
        case .edit:
            self.titleLabel.text = "Edit Profile"
            break
        case .password:
            self.titleLabel.text = "Change Password"
            break
        case .logout:
            self.titleLabel.text = "Logout"
            break
        case .invite:
            self.titleLabel.text = "Invite a friend"
            break
        case .rateApp:
            self.titleLabel.text = "Rate our app"
            break
        }
    }
}
