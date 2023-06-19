//
//  FullscreenHighlightView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 6/8/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI

struct FullscreenHighlightView: View {
    @AppStorage("numHighlights") var numHighlights: Int = 12
    @Binding var tabSelection: ContentView.Tab
    @AppStorage("userGroupId") var userGroupId: String = ""
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Number of Highlights")
                Picker("Number of Highlights", selection: $numHighlights) {
                    Text("12").tag(12)
                    Text("24").tag(24)
                    Text("36").tag(36)
                    Text("48").tag(48)
                    Text("60").tag(60)
                }
            }
               
            HighlightView(numItems: numHighlights, tabSelection: $tabSelection)
        }
        .navigationTitle(Text("Group \(userGroupId)"))
    }
}

