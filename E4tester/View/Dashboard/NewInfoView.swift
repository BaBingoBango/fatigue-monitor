//
//  NewInfoView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/8/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI

/// An app view written in SwiftUI!
struct NewInfoView: View {
    
    // MARK: View Variables
    @State var isShowingFatigueDetail = false
    @State var isShowingHeatStrainDetail = false
    
    // MARK: View Body
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingFatigueDetail = true
                }) {
                    MetricWidgetView(title: "Fatigue", numberString: "60", unitString: "%", severity: "Moderate Risk", color: .orange)
                }
                .sheet(isPresented: $isShowingFatigueDetail) {
                    MetricsDetailView(fatigue: 60, heatStrain: 0, selectedMetric: .fatigue)
                }
                
                Button(action: {
                    isShowingHeatStrainDetail = true
                }) {
                    MetricWidgetView(title: "Heat Strain", numberString: "3", unitString: "PSI", severity: "Low Risk", color: .green)
                }
                .sheet(isPresented: $isShowingHeatStrainDetail) {
                    MetricsDetailView(fatigue: 60, heatStrain: 0, selectedMetric: .heatStrain)
                }
            }
            
            HStack(spacing: 5) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .dynamicFont(.title, padding: 0)
                
                HStack(alignment: .bottom, spacing: 3) {
                    Text("\(72)")
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                    
                    Text("BPM")
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                        .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                        .padding(.bottom, 2)
                }
                
                Spacer()
                
                Text("Collecting Data")
                    .foregroundStyle(.secondary)
                    .fontWeight(.bold)
                    .dynamicFont(.body, padding: 0)
            }
            .padding()
            .modifier(RectangleWrapper(color: .secondary.opacity(0.10)))
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct NewInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NewInfoView()
    }
}

// MARK: Support Views
struct MetricWidgetView: View {
    
    // View Variables
    var title: String
    var numberString: String
    var unitString: String
    var severity: String
    var color: Color
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(title.uppercased())
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .dynamicFont(.title3, padding: 0)
                
                HStack(alignment: .bottom, spacing: 3) {
                    Text(numberString)
                        .fontWeight(.bold)
                        .dynamicFont(.system(size: 50), fontDesign: .rounded, padding: 0)
                        .foregroundStyle(color)
                    
                    Text(unitString)
                        .fontWeight(.bold)
                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                        .foregroundStyle(color)
                        .offset(y: -7)
                }
                
                Text(severity)
                    .fontWeight(.bold)
                    .dynamicFont(.title2, padding: 0)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Spacer()
            
            Group {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .dynamicFont(.title3, padding: 0)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .padding()
        .modifier(RectangleWrapper(color: color.opacity(0.10)))
        .aspectRatio(1.2, contentMode: .fit)
    }
}
