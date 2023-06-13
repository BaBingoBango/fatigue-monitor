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
    
    /// Initialize `data` from start date.
    init() {
        let startDate = Date(timeIntervalSince1970: userStartDate).startOfDay
        data = [
            (startDate.startOfDay, ["1st in-person survey", "Online fatigue survey"]),
            (Utilities.addDaysExcludingWeekends(startDate, 1), ["Online fatigue survey"]),
            (Utilities.addDaysExcludingWeekends(startDate, 5), ["2nd in-person survey"]),
            (Utilities.addDaysExcludingWeekends(startDate, 9), ["3rd in-person survey", "Usefulness interview", "Return device & Get rewarded!"]),
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
                        if Utilities.daysFromToday(date) > 0 { // future
                            Image(systemName: "dot.square.fill")
                                .resizable()
                                .foregroundColor(Color(white: 0.5))
                                .background(DarkMode.isDarkMode() ? .black : .white)
                                .frame(width: imageSize, height: imageSize)
                        }
                        else if Utilities.daysFromToday(date) < 0 { // past
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
                            Text(Utilities.dateToString(date))
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
                        .foregroundColor(DarkMode.isDarkMode() ? Color(white: 0.2) : Color(white: 0.8))
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
    
}
