//
//  HighlightView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/23/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI
import SkeletonUI

struct HighlightView: View {
    
    @ObservedObject var warningLoader = FatigueWarningLoader()
    @State var firstLoaded: Bool = false
    
    @AppStorage("highlightLastFetched") var highlightLastFetched: Double = 0
    
    /// Constructor
    init(numItems: Int = 2) {
        FirebaseManager.connect()
        FirebaseManager.getFatigueWarnings(loader: warningLoader,
                                           numItems: numItems)
        
//        // outdated highlight, fetch
//        if Date().timeIntervalSince1970 - highlightLastFetched > 60 {
//            FirebaseManager.connect()
//            FirebaseManager.getFatigueWarnings(loader: warningLoader,
//                                               numItems: numItems)
//            highlightLastFetched = Date().timeIntervalSince1970
//        }
//        // reuse previously fetched data
//        else {
//            warningLoader = UserDefaults.standard.object(forKey: "lastHighlight") as? FatigueWarningLoader ?? FatigueWarningLoader()
//        }
        
        
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
                    .frame(width: 370, height: 60)
                    .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                    .cornerRadius(16)
                }
                
            }
            else {
                // done loading!
                if warningLoader.data.count == 0 {
                    Text("No hightlights in your group.")
                }
                
                // Highlights
                ForEach(warningLoader.data.indices) { index in
                    let warning = warningLoader.data[index]
                    HighlightItem(icon: "exclamationmark.triangle.fill",
                                  iconColor: .yellow,
                                  name: warning.firstName,
                                  text: warning.content,
                                  timeAgo: warning.timeAgo()) // declaration below
                }
                Spacer()
            }
            
        }
        .frame(width: 360)
        
    }
    
    
}


struct HighlightItem: View {
    
    var icon: String // leave empty ("") for no icon
    var iconColor: Color = .black
    var name: String
    var text: String
    var timeAgo: String
    
    var body: some View {
        HStack {
            Spacer()
            // icon
            if icon != "" {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .imageScale(.medium)
            }
            // text
            Text(name)
                .font(.system(size: 15, weight: .semibold))
            
            VStack(alignment: .leading) {
                Text(text)
                    .font(.system(size: 15))
                Text(timeAgo)
                    .font(.system(size: 10))
            }
            
            
            Spacer()
        }
        .frame(width: 360, height: 60)
        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
        .cornerRadius(16)
    }
}
