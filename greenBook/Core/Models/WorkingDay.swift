//
//  WorkingDay.swift
//  greenBook
//
//  Created by Mostafa on 11/14/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
class WorkingDay : BaseModel {
    var day_name : String = ""
    var opened_at : String = ""
    var closed_at : String = ""
    var state : String = ""
    
    override func bindDictionary(dict: [String : Any]) {
        super.bindDictionary(dict: dict)
        
        if let value = dict["day_name"] as? String {
            self.day_name = value
        }
        
        if let value = dict["opened_at"] as? String {
            self.opened_at = value
        }
        
        if let value = dict["closed_at"] as? String {
            self.closed_at = value
        }
        if let value = dict ["state"] as? String {
            self.state = value
        }
    }
    static let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    func liesWithin() -> Bool {
        let date = Date() // time utc
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        if let weekDay = components.weekday, WorkingDay.weekDays.count > components.weekday! {
            if WorkingDay.weekDays[weekDay] == self.day_name {
                // Same Day, Start Parsing Time
                let dateFormatter = DateFormatter.init()
                dateFormatter.dateFormat = "hh:mm a"
                if let startDate = dateFormatter.date(from: self.opened_at), let closeDate = dateFormatter.date(from: self.closed_at) {
                    if date.compare(startDate).rawValue != CFComparisonResult.compareLessThan.rawValue, date.compare(closeDate).rawValue != CFComparisonResult.compareGreaterThan.rawValue {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isOpen() -> Bool {
        return state == "opened"
    }
}
