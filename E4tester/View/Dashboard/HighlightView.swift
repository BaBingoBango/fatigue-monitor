//
//  HighlightView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/23/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI
import SkeletonUI

/// Shows highlights
///
/// ### Usage
/// `HighlightView(numItems: 10)`
///
struct HighlightView: View {
    
    @ObservedObject var warningLoader = FatigueWarningLoader()
    @State var firstLoaded: Bool = false
    @State var showDoSurvey: Bool = false
    
    @Binding var tabSelection: ContentView.Tab
    
    @AppStorage("highlightLastFetched") var highlightLastFetched: Double = 0
    
    
    /// Constructor
    init(numItems: Int = 2, tabSelection: Binding<ContentView.Tab>) {
        self._tabSelection = tabSelection
        // User has survey to do today?
        let (surveyAvailable, _) = SurveyManager.sufficientTimePassed()
        let doSurvey = SurveyManager.doSurveyToday()
        
        if doSurvey && surveyAvailable {
            _showDoSurvey = State(initialValue: true)
            FirebaseManager.connect()
            FirebaseManager.getFatigueWarnings(loader: warningLoader,
                                               numItems: numItems - 1)
        }
        else {
            _showDoSurvey = State(initialValue: false)
            FirebaseManager.connect()
            FirebaseManager.getFatigueWarnings(loader: warningLoader,
                                               numItems: numItems)
        }
    }
    
    
    var body: some View {
        VStack {
            
            if warningLoader.loading {
                // Is loading: show skeleton
                ForEach(1..<3) { index in
                    HStack {
                        Text("Loading")
                            .skeleton(with: true,
                                      size: CGSize(width: 80, height: 15))
                        VStack(alignment: .leading) {
                            Text("Loading...")
                                .skeleton(with: true,
                                          size: CGSize(width: 220, height: 15))
                            Text("Loading...")
                                .skeleton(with: true,
                                          size: CGSize(width: 120, height: 10))
                        }
                        
                    }
                    .frame(width: 360, height: 60)
                    .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                    .cornerRadius(16)
                }
                
            }
            else {
                // done loading!
                if warningLoader.data.count == 0 {
                    Text("No highlights in your group.")
                }
                
                // Do survey?
                if showDoSurvey {
                    Button(action: {
                        tabSelection = .survey
                    }) {
                        HighlightItem(icon: "square.and.pencil",
                                      iconColor: .cyan,
                                      name: "Survey",
                                      text: "Please complete the fatigue survey!",
                                      showArrow: true) // declaration below
                    }
                    .foregroundColor(DarkMode.isDarkMode() ? .white : .black)
                    
                }
                
                // Highlights
                ForEach(warningLoader.data.indices) { index in
                    let warning = warningLoader.data[index]
                    HighlightItem(icon: "exclamationmark.triangle.fill",
                                  iconColor: DarkMode.isDarkMode() ? .yellow : .orange,
                                  name: warning.firstName,
                                  text: warning.content,
                                  timeAgo: warning.timeAgo()) // declaration below
                }
                Spacer()
            }
            
        }
        .frame(width: 360)
        .onAppear {
            let (surveyAvailable, _) = SurveyManager.sufficientTimePassed()
            let doSurvey = SurveyManager.doSurveyToday()
            
            if doSurvey && surveyAvailable {
                showDoSurvey = true
            }
            else {
                showDoSurvey = false
            }
        }
        
    }
    
    
}

/// View for each highlight item.
struct HighlightItem: View {
    
    var icon: String // leave empty ("") for no icon
    var iconColor: Color = .black
    var name: String
    var text: String
    var timeAgo: String = ""
    var showArrow: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            
            // icon
            if icon != "" {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .imageScale(.large)
            }
            
            Spacer()
                .frame(width: 12)
            
            // text
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                    Text(timeAgo)
                        .font(.system(size: 10))
                }
                Text(text)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "greaterthan")
                    .resizable()
                    .frame(width: 6, height: 12)
                    .foregroundColor(Color(white: 0.5))
                    .offset(x: -16)
            }
        }
        .frame(width: 360, height: 60)
        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
        .cornerRadius(16)
    }
}
