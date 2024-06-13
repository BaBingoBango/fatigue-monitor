//
//  TipsView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/4/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI

/// An app view written in SwiftUI!
struct TipsView: View {
    
    // MARK: View Variables
    @State var selectedMetric: MetricType = .fatigue
    
    // MARK: View Body
    var body: some View {
        Picker("", selection: $selectedMetric) {
            Text("Fatigue").tag(MetricType.fatigue)
            Text("Heat Strain").tag(MetricType.heatStrain)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

// MARK: Support Views
// Support views go here! :)
