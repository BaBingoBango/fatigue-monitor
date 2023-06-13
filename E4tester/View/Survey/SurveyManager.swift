//
//  SurveyManager.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 6/6/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import Foundation

/// Handles all survey-related administrative actions.
class SurveyManager {
    /// Returns the number of surveys submitted by the user today.
    static func surveysSubmittedToday() -> Int {
        var count: Int = 0
        let todayMidnight = Date().startOfDay.timeIntervalSince1970
        let endTime = todayMidnight + 86400; // + 1 day
        
        let curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        for timestamp in curArr {
            if timestamp > todayMidnight && timestamp < endTime { // today
                count += 1
            }
        }
        
        return count
    }
    
    /// Returns whether user should do a survey today.
    static func doSurveyToday() -> Bool {
        let startDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "userStartDate")).startOfDay
        let today = Date().startOfDay
        return (today == startDate ||
            today == Utilities.addDaysExcludingWeekends(startDate, 1))
    }
    
    /// Returns a pair of string and bool:
    /// - Bool: true if sufficient time (default 60 min) has passed since last survey submission, false otherwise
    /// - String: next earliest time user can submit a form if false. Trivial value returned when returning true
    static func sufficientTimePassed() -> (Bool, String) {
        let minTime: Double = 3600 // seconds
        let curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        if curArr.isEmpty { // first response
            return (true, "")
        }
        
        let now = Date().timeIntervalSince1970
        let nextEarliest = curArr.last! + minTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let ok: Bool = nextEarliest - 60 < now // minus 1 minute for some flexibility
        let time = dateFormatter.string(from: Date(timeIntervalSince1970: nextEarliest))
        return (ok, time)
    }
    
    /// Adds survey timestamp to AppStorage
    static func addSurveyTimestamp(_ timestamp: Double) {
        var curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        curArr.append(timestamp)
        UserDefaults.standard.set(curArr, forKey: "submittedSurveyTimestamps")
    }
}
