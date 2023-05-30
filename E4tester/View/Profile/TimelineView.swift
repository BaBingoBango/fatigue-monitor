//
//  TimelineView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/30/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI
import SkeletonUI

/// Timeline view
struct TimelineView: View {
    
    /// Data to be displayed on the timeline. Array of pairs of
    /// - Date:start date of each day (example: `Date().startOfDay`)
    /// - [String]: array of strings, displayed in separate lines
    /// Will be displayed in the order of array
    /// size must be 2 or greater
    var data: [(Date, [String])] = [
        (Date(timeInterval: -86400, since: Date()).startOfDay, ["Yesterday"]),
        (Date().startOfDay, ["Today"]),
        (Date(timeInterval: 86400, since: Date()).startOfDay, ["Tomorrow", "Hello world"]),
        (Date(timeInterval: 86400*2, since: Date()).startOfDay, ["The day after tomorrow", "Woof woof"])
    ] // dummy data
    
    @State var toggleToRefresh: Bool = false

    @AppStorage("userStartDate") var userStartDate: Double = 0
    init() {
        let startDate = Date(timeIntervalSince1970: userStartDate).startOfDay
        data = [
            (startDate.startOfDay, ["1st in-person survey", "Online fatigue survey"]),
            (addDaysExcludingWeekends(startDate, 1), ["Online fatigue survey"]),
            (addDaysExcludingWeekends(startDate, 5), ["2nd in-person survey"]),
            (addDaysExcludingWeekends(startDate, 9), ["3rd in-person survey", "Usefulness interview", "Return device & Get rewarded!"]),
        ]
    }
    
    var body: some View {
        var counter: Int = 0
        VStack(alignment: .leading) {
            // header
            HStack {
                Image(systemName: "calendar")
                    .imageScale(.large)
                Text("Timeline")
                    .font(.system(size: 20, weight: .bold))
            }
            .frame(width: 350, alignment: .center)
            .padding(.bottom, 16)
            
            // timeline
            ForEach(data.indices) { index in
                let date = data[index].0
                let value = data[index].1
                let imageSize: CGFloat = 24
                
                // timeline item
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        // icon
                        if daysFromToday(date) > 0 { // future
                            Image(systemName: "dot.square.fill")
                                .resizable()
                                .foregroundColor(Color(white: 0.5))
                                .background(DarkMode.isDarkMode() ? .black : .white)
                                .frame(width: imageSize, height: imageSize)
                        }
                        else if daysFromToday(date) < 0 { // past
                            Image(systemName: "checkmark.square.fill")
                                .resizable()
                                .foregroundColor(Color(red: 52/255, green: 178/255, blue: 51/255))
                                .background(DarkMode.isDarkMode() ? .black : .white)
                                .frame(width: imageSize, height: imageSize)
                        }
                        else { // today
                            Image(systemName: "exclamationmark.square.fill")
                                .resizable()
                                .foregroundColor(.yellow)
                                .background(DarkMode.isDarkMode() ? .black : .white)
                                .frame(width: imageSize, height: imageSize)
                        }
                        
                        
                        // text
                        VStack(alignment: .leading) {
                            Text(dateToString(date))
                                .font(.system(size: 16, weight: .bold))
                                .padding(.bottom, -4)
                            ForEach(value.indices) { index in
                                Text(value[index])
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.leading, 12)
                    }
                    .padding([.horizontal], 10)
                } // vstack
                .padding([.horizontal], 12)
                .padding(.bottom, 4)
                .cornerRadius(16)
                
                // line
                if index > 0 {
                    let prevItemLineCount: Int = data[index-1].1.count
                    let thisItemLineCount: Int = data[index].1.count
                    let lineHeight: CGFloat = CGFloat(42 + (prevItemLineCount * 20))
                    let thisItemHeight: CGFloat = CGFloat(thisItemLineCount * 20)

                    let xOffset: CGFloat = CGFloat(imageSize / 2) + 21
                    let yOffset: CGFloat = -1 * CGFloat(lineHeight + 24 + thisItemHeight)

                    Rectangle()
                        .frame(width: 2, height: lineHeight)
                        .foregroundColor(Color(white: 0.5))
                        .background(DarkMode.isDarkMode() ? .black : .white)
                        .offset(x: xOffset, y: yOffset)
                        .padding(.bottom, -1 * lineHeight)
                        .zIndex(-999)
                }
                else {
                    Rectangle()
                        .frame(width: 2, height: 0)
                        .padding(.bottom, 0)
                }
            }
        }
        .padding([.horizontal], 24)
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        return dateFormatter.string(from: date)
    }
    
    func daysFromToday(_ date: Date) -> Int {
        let today = Date().startOfDay
        return Int(date.timeIntervalSince1970 - today.timeIntervalSince1970) / 86400
    }
    
    /// Adds `days` days to `date`, excluding weekends
    func addDaysExcludingWeekends(_ date: Date, _ days: Int) -> Date {
        var daysToAdd: Int = days
        var result: Date = date
        
        while daysToAdd > 0 {
            result.addTimeInterval(86400)
            
            // account for weekends
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
    
}
