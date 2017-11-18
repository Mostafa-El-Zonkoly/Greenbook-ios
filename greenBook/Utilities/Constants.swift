//
//  Constants.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation


struct URLS {
    static let SERVER_URL = "https://staging-greenbook.herokuapp.com/api/v1/"
    static let SIGNUP_URL = "\(SERVER_URL)users"
    static let LOGIN_URL = "\(SERVER_URL)users/sign_in"
    static let FORGET_PASSWORD_URL = "\(SERVER_URL)users/password"
    static let CATEGORIES_URL = "\(SERVER_URL)categories"
    static let SEARCH_URL = "\(SERVER_URL)shops/search"
    static let FAV_URL = "\(SERVER_URL)shops/favourites"
}
struct Messages {
    static let DEFAULT_ERROR_MSG = "Something went wrong"
}

