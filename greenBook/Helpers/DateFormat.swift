//
//  DateFormat.swift
//  Shaifak
//
//  Created by Mostafa on 11/18/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import Foundation
extension String {
    
    func dateFormatted(format: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            let date = dateFormatter.date(from: self)
            return date
    }
    func dateForHours() -> Date? {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "hh:mm a"
        if let hoursDate = dateFormatter.date(from: self){
            var gregorian = Calendar(identifier: .gregorian)
            var dateComponents = gregorian.dateComponents([.hour, .minute], from: hoursDate)
            gregorian.timeZone = TimeZone.init(secondsFromGMT: 0)!
            var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: Date())

            components.hour = dateComponents.hour
            components.minute = dateComponents.minute
            if let todaysDate = gregorian.date(from: components) {
                return todaysDate
            }

        }
        return Date()
    }
}

extension Date {
    
    func dateRep(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let representation = dateFormatter.string(from: self)
        
        let now = Date()
        var diffSecs = now.timeIntervalSince(self) // Time interval in seconds
        let seconds = diffSecs.truncatingRemainder(dividingBy: 60.0)
        diffSecs = (diffSecs - seconds)/60.0 // in min
        let min = diffSecs.truncatingRemainder(dividingBy: 60.0)
        diffSecs = (diffSecs - min)/60.0 // in hours
        let hours = diffSecs.truncatingRemainder(dividingBy: 24.0)
        diffSecs = (diffSecs - hours)/24.0 // in days
        let days = diffSecs.truncatingRemainder(dividingBy: 7)
//        diffSecs = (diffSecs - days)/7.0 // in weeks
        if diffSecs != 0 {
            // Difference is in days
            if diffSecs == 1 {
                return "1 day ago"
            }else if diffSecs <= 7 {
                return "\(Int(days)) days ago"
            }else{
                return representation
            }
        }else{
            if hours != 0 {
                if hours == 1 {
                    return "1 hour ago"
                }
                return "\(Int(hours)) hours ago"
            }else{
                if min != 0 {
                        return "\(Int(min)) min ago"
                }else{
                    return "Seconds ago"
                }
            }
        }
    }
}
