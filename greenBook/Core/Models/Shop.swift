//
//  Shop.swift
//  greenBook
//
//  Created by Mostafa on 11/13/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
import CoreLocation


class Shop: BaseModel {
    var shopDescription = ""
    var name : String = ""
    var rate : Double = 0
    var num_of_reviews : Int = 0
    var workingDays : [WorkingDay] = []
    var location : Location = Location()
    var main_photo_url : String = ""
    var photos : [Photo] = []
    var phone_number : String = ""
    var google_place_id : String = ""
    var open_now : Bool = false
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        if let value = dict["photos"] as? [[String : Any]] {
            self.photos = []
            for photoDict in value {
                let photo = Photo()
                photo.bindPhoto(dict: photoDict)
                photos.append(photo)
            }
        }
        if let value = dict["google_place_id"] as? String {
            self.google_place_id = value
        }
        if let value = dict["phone_number"] as? String {
            self.phone_number = value
        }else{
            self.phone_number = "   "
        }
        if let value = dict["main_photo_url"] as? String {
            self.main_photo_url = value
        }
        if let value = dict["location"] as? [String : Any] {
            self.location = Location()
            self.location.bindDictionary(dict: value)
        }
        if let value = dict["open_now"] as? Bool {
            self.open_now = value
        }
        if let value = dict["working_days"] as? [[String : Any]] {
            self.workingDays = []
            for wdDict in value {
                let workingDay = WorkingDay()
                workingDay.bindDictionary(dict: wdDict)
                self.workingDays.append(workingDay)
            }
        }

        if let value = dict["num_of_reviews"] as? Int {
            self.num_of_reviews = value
        }

        if let value = dict["description"] as? String {
            self.shopDescription = value
        }
        if let value = dict["name"] as? String {
            self.name = value
        }
        if let value = dict["rate"] as? Double {
            self.rate = value
        }
        if let _ = ShopManager.sharedInstance.favouriteShops[self.google_place_id] {
            ShopManager.sharedInstance.favouriteShops[self.google_place_id] = self.google_place_id
            ShopManager.sharedInstance.cacheFavourite()
        }
    }
    
    func favourited() -> Bool {
        return ShopManager.sharedInstance.favouriteShops[self.google_place_id] != nil
    }
    
    
    func getDistance() -> String {
        if let location = CLLocationManager().location {
            
           let distance =  (location.distance(from: CLLocation.init(latitude: self.location.lat, longitude: self.location.long)) / 1000.0).toMile()
            
            return "\(max(distance, 0).toString(decimals: 2)) Miles from you"
        }
        return "Unkown"
    }
    
    func isOpen() -> Bool {
//        for workDay in workingDays {
//            if workDay.liesWithin() {
//                return workDay.isOpen()
//            }
//        }
//        return false
        return open_now
    }
    
    func isOpenText() -> String {
                for workDay in workingDays {
                    if workDay.liesWithin() {
                        return workDay.opening_hours
                    }
                }
        
        if isOpen() {
            return "Not Determined"
        }else{
            return "Not Determined"
        }
    }
    override func toDict() -> [String : Any] {
        var dict : [String : Any] = [:]
        /*
         var shopDescription = ""
         var name : String = ""
         var rate : Double = 0
         var num_of_reviews : Int = 0
         var workingDays : [WorkingDay] = []
         var location : Location = Location()
         var main_photo_url : String = ""
         var photos : [Photo] = []
         var phone_number : String = ""*/
        
        return dict
    }
    func getHours() -> [String] {
        var hours : [String] = []
        var hoursDict : [String : WorkingDay] = [:]
        for workingDay in workingDays {
            hoursDict[workingDay.day_name.lowercased()] = workingDay
        }
        var calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        // Keep local time zone
        //        if let timeZone = TimeZone.init(secondsFromGMT: 0) {
        //            calendar.timeZone = timeZone
        //        }
        let date = Date() // time utc
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        if let weekDay = components.weekday, WorkingDay.weekDays.count >= components.weekday! {
            let startingIndex = weekDay - 1
            var index = startingIndex
            while hoursDict.keys.count > 0 {
                let workDay = WorkingDay.weekDays[index]
                if let day = hoursDict[workDay.lowercased()] {
                    hours.append(day.opening_hours)
                    hoursDict.removeValue(forKey: workDay.lowercased())
                }
                index = (index + 1) % WorkingDay.weekDays.count
                if index == startingIndex {
                    break
                }
            }
        }
        
        return hours
    }
}

extension Double {
    func toMile() -> Double {
        return self * 0.621371
    }
}
