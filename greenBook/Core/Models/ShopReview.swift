//
//  ShopReview.swift
//  greenBook
//
//  Created by Mostafa on 11/19/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation

class ShopReview: BaseModel {
    /*
     "id": 40,
     "rate": 5,
     "description": "Great Place",
     "created_at": "2017-10-31T22:20:19.423Z",
     "reply": null,
     "date_replied": null,
     "user": {
     "id": 19,
     "name": "ahmed saleh",
     "image_url": "https://firebasestorage.googleapis.com/v0/b/greenbook-e6f97.appspot.com/o/clients%2Fad6a4cdb-6872-41b6-a4d8-fc8376f4ef75?alt=media&token=55ffeaff-60d0-4ce1-ba4b-437bbf16941a"
     }
     */
    var rate : Int = 0
    var review: String = ""
    var created_at : String = ""
    var user : User = User()
    var date : Date = Date()
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["rate"] as? Int {
            self.rate = value
        }
        if let value = dict["description"] as? String {
            self.review = value
        }
        if let value = dict["created_at"] as? String {
            self.created_at = value
            if let serverDate =  self.created_at.dateFormatted(format: DateFormats.SERVER_DATE_FORMAT) {
                self.date = serverDate
            }
        }
        if let userDict = dict["user"] as? [String : Any] {
            user = User()
            user.bindDictionary(dict: userDict)
        }
    }
    
    func getDateFormatted() -> String {
        return self.date.dateRep(format: DateFormats.DATE_REP_FORMAT)
    }
    
}
