//
//  MetricsDetailView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/10/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI

/// An app view written in SwiftUI!
struct MetricsDetailView: View {
    
    // MARK: View Variables
    /// Whether or not this view is presented.
    @Environment(\.presentationMode) var presentationMode
    /// ???
    var fatigue: Int = 60
    /// ???
    var heatStrain: Int = 0
    /// ???
    @State var selectedMetric: MetricType = .fatigue
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("", selection: $selectedMetric) {
                        Text("Fatigue").tag(MetricType.fatigue)
                        Text("Heat Strain").tag(MetricType.heatStrain)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    switch selectedMetric {
                    case .fatigue:
                        MetricDetailView(metric: .fatigue(value: fatigue))
                    case .heatStrain:
                        MetricDetailView(metric: .heatStrain(value: heatStrain))
                    }
                }
            }
            
            // MARK: Navigation Settings
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            })
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct MetricsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsDetailView()
    }
}

// MARK: Support Views
// Support views go here! :)
