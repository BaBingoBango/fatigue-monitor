//
//  FullscreenHighlightView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 6/8/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI

struct FullscreenHighlightView: View {
    @Binding var tabSelection: ContentView.Tab
    
    var body: some View {
        GeometryReader { metrics in
            NavigationView {
                ScrollView {
                    HighlightView(numItems: 12, tabSelection: $tabSelection)
                }
                .frame(width: metrics.size.width)
            }
            .frame(width: metrics.size.width)
            .navigationTitle(Text("Highlights"))
        }
    }
}

