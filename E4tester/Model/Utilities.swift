//
//  Utilities.swift
//  E4tester
//
//  Created by Waley Zheng on 7/26/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation
import SwiftUI

class Utilities {
    
    /// Adds `days` days to `date`, excluding weekends
    /// O(number of days) - not intended for dates that are more than a month apart
    static func addDaysExcludingWeekends(_ date: Date, _ days: Int) -> Date {
        var daysToAdd: Int = days
        var result: Date = date
        
        while daysToAdd > 0 {
            result.addTimeInterval(86400)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            
            if dateFormatter.string(from: result) == "Sat" {
                result.addTimeInterval(86400 * 2)
            }
            else if dateFormatter.string(from: result) == "Sun" {
                result.addTimeInterval(86400)
            }
            
            daysToAdd -= 1
        }
        
        return result
    }
    
    /// Returns the number of days from today.
    /// e.g. if `date` = Jan 1 and today = Jan 5, returns -4
    static func daysFromToday(_ date: Date) -> Int {
        let today = Date().startOfDay
        return Int(date.timeIntervalSince1970 - today.timeIntervalSince1970) / 86400
    }
    
    /// Converts date object to string in `EEE, MMM, d` format
    /// e.g. "Mon, Jan 1"
    static func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        return dateFormatter.string(from: date)
    }
}

extension Color {
    static let Colors: [Color] = [
        Color(red: 4/255, green: 116/255, blue: 186/255),
        Color(red: 255/255, green: 166/255, blue: 48/255),
        Color(red: 92/255, green: 92/255, blue: 92/255),
        Color(red: 107/255, green: 189/255, blue: 96/255),
        Color(red: 0/255, green: 167/255, blue: 225/255),
        Color(red: 255/255, green: 166/255, blue: 0)
    ]
    
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    static func getColor(withIndex index: Int) -> Color {
        return Colors[index % 6]
    }
}

// convert timestamp to date string
func ts2date(timestamp: Double) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
    dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    return strDate
}

// trim white spaces and newlines around string
func trimStr(str: String) -> String {
    return str.trimmingCharacters(in: .whitespacesAndNewlines)
}

func fileURL() throws -> URL {
    try FileManager.default.url(for: .documentDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: false)
        .appendingPathComponent("user.data")
}

// if timestamp is less than n hours from now
func ifLessThanNHours(timestamp: Double, hours: Double) -> Bool {
    return (Date().timeIntervalSince1970 - timestamp <= hours * 3600)
}

class DarkMode {
    /// Detects if dark mode is enabled or not.
    static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
