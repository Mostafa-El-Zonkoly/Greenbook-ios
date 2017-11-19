//
//  Constants.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import UIKit

struct URLS {
    static let SERVER_URL = "https://staging-greenbook.herokuapp.com/api/v1/"
    static let SIGNUP_URL = "\(SERVER_URL)users"
    static let LOGIN_URL = "\(SERVER_URL)users/sign_in"
    static let FORGET_PASSWORD_URL = "\(SERVER_URL)users/password"
    static let CATEGORIES_URL = "\(SERVER_URL)categories"
    static let SEARCH_URL = "\(SERVER_URL)shops/search"
    static let FAV_URL = "\(SERVER_URL)shops/favourites"
    static let SHOP_REVIEWS_URL = "\(SERVER_URL)shops/%d/reviews"
}
struct Messages {
    static let DEFAULT_ERROR_MSG = "Something went wrong"
}

struct Colors {
    static let NAVIGATION_COLOR = UIColor.init(red: 2.0/255.0, green: 120.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    static let SELECTED_SEGMENT_TEXT_COLOR = UIColor.init(red: 2.0/255.0, green: 120.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    static let IDLE_SEGMENT_TEXT_COLOR = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    static let SEPARATOR_COLOR = UIColor.init(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)

}

struct Fonts {
    static let NavigationTitleFont = UIFont.init(name: "OpenSans", size: 18.0)!
}

struct DateFormats{
    /*2017-10-31T22:20:19.423Z*/
    static let SERVER_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let DATE_REP_FORMAT = "MMM dd 'at' h:mm a"

}
