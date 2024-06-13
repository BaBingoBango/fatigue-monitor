//
//  FatigueView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/7/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI

/// An app view written in SwiftUI!
struct MetricDetailView: View {
    
    // MARK: View Variables
    /// The metric this view is currently displaying.
    var metric: Metric
    /// Whether or not this view is presented.
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: View Body
    var body: some View {
//        NavigationView {
//            ScrollView {
                VStack(alignment: .leading) {
                    switch metric {
                    case .fatigue(let value):
                        if value < 40 {
                            MetricDisplayView(iconName: "battery.100percent", iconColor: .green, header: "Low Fatigue Risk", subtext: "You're doing great!")
                                .padding(.top, 5)
                            
                        } else if value < 70 {
                            MetricDisplayView(iconName: "battery.75percent", iconColor: .orange, header: "Moderate Fatigue Risk", subtext: "You need to be cautious.")
                                .padding(.top, 5)
                            
                        } else if value < 90 {
                            MetricDisplayView(iconName: "battery.50percent", iconColor: .red, header: "High Fatigue Risk", subtext: "You need to recover now!")
                                .padding(.top, 5)
                            
                            
                        } else {
                            MetricDisplayView(iconName: "battery.25percent", iconColor: .red, header: "Critical Fatigue Risk", subtext: "You need to recover now!")
                                .padding(.top, 5)
                            
                        }
                    case .heatStrain(let value):
                        if value < 1 {
                            MetricDisplayView(iconName: "thermometer.low", iconColor: .green, header: "Low Heat Risk", subtext: "You're doing great!", extraPadding: 10)
                                .padding(.top, 5)
                            
                        } else if value < 2 {
                            MetricDisplayView(iconName: "thermometer.medium", iconColor: .orange, header: "Moderate Heat Risk", subtext: "You need to be cautious.", extraPadding: 10)
                                .padding(.top, 5)
                            
                        } else if value < 3 {
                            MetricDisplayView(iconName: "thermometer.high", iconColor: .red, header: "High Heat Risk", subtext: "You need to cool down now!", extraPadding: 10)
                                .padding(.top, 5)
                            
                            
                        } else {
                            MetricDisplayView(iconName: "thermometer.high", iconColor: .red, header: "Critical", subtext: "You need to cool down now!", extraPadding: 10)
                                .padding(.top, 5)
                            
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Why is it so important?")
                            .fontWeight(.bold)
                            .dynamicFont(.title2)
                            .padding(.top)
                        
                        Text({
                            switch metric {
                            case .fatigue(_):
                                "Accumulated fatigue can harm you..."
                            case .heatStrain(_):
                                "Excessive heat strain can lead to..."
                            }
                        }())
                            .dynamicFont(.body)
                        
                        switch metric {
                        case .fatigue(_):
                            IconRowView(imageName: "physical", header: "Physically", subtext: "Lack of energy")
                            IconRowView(imageName: "mental", header: "Mentally", subtext: "Inattentiveness, distraction")
                            IconRowView(imageName: "emotional", header: "Emotionally", subtext: "Frustration, depression")
                            
                        case .heatStrain(_):
                            IconRowView(imageName: "fatal", header: "Serious health problems", subtext: "Heat exhaustion and heatstroke")
                            IconRowView(imageName: "preventable", header: "Even fatalities", subtext: "36 deaths on job sites in 2021")
                        }
                    }
                    .padding(.bottom)
                    .modifier(RectangleWrapper(color: .secondary.opacity(0.10)))
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text({
                            switch metric {
                            case .fatigue(_):
                                "Reducing Fatigue"
                            case .heatStrain(_):
                                "Reducing Heat Strain"
                            }
                        }())
                            .fontWeight(.bold)
                            .dynamicFont(.title2, lineLimit: 2)
                            .padding(.top)
                        
                        switch metric {
                        case .fatigue(_):
                            IconRowView(imageName: "nap", header: "Take a short nap during break", subtext: "It can help you to recover fatigue!")
                            IconRowView(imageName: "balance", header: "Balance your works", subtext: "Your workload need to be adjusted!")
                            IconRowView(imageName: "water", header: "Maintain hydration", subtext: "Fuel your body to recover!")
                            IconRowView(imageName: "adjust", header: "Adjust working environment", subtext: "It helps you to reduce fatigue!")
                            
                        case .heatStrain(_):
                            IconRowView(imageName: "hydration", header: "Maintaining hydration", subtext: "Fuel your body to recover!")
                            IconRowView(imageName: "rest", header: "Taking a rest in cool, shady places", subtext: "It helps you cool it down!")
                            IconRowView(imageName: "dress", header: "Get dressed in a cool way", subtext: "It prevents you from getting hot!")
                            IconRowView(imageName: "monitor", header: "Knowing the signs", subtext: "Tracking your conditions can help you!")
                            IconRowView(imageName: "together", header: "Alter your schedule", subtext: "Try to schedule heavy work and hot jobs for cooler parts of the day")
                        }
                    }
                    .padding(.bottom)
                    .modifier(RectangleWrapper(color: {
                        switch metric {
                        case .fatigue(let value):
                            if value < 40 {
                                return .secondary.opacity(0.10)
                            } else if value < 70 {
                                return .orange.opacity(0.10)
                            } else if value < 90 {
                                return .red.opacity(0.10)
                            } else {
                                return .red.opacity(0.10)
                            }
                        case .heatStrain(let value):
                            if value < 1 {
                                return .secondary.opacity(0.10)
                            } else if value < 2 {
                                return .orange.opacity(0.10)
                            } else if value < 3 {
                                return .red.opacity(0.10)
                            } else {
                                return .red.opacity(0.10)
                            }
                        }
                    }()))
                    .padding(.horizontal)
                    
                    switch metric {
                    case .fatigue(_):
                        EmptyView()
                    case .heatStrain(_):
                        
                        Text("Signs of Heat Conditions")
                            .fontWeight(.bold)
                            .padding(.top)
                            .dynamicFont(.title2)
                        
                        Image("exhaustion")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .padding()
                        
                        Image("stroke")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .padding()
                    }
                }
                .padding(.bottom)
//            }
            
            // MARK: Navigation Settings
//            .navigationTitle({
//                switch metric {
//                case .fatigue(_):
//                    return "Fatigue"
//                case .heatStrain(_):
//                    return "Heat Strain"
//                }
//            }())
//            .toolbar(content: {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button(action: {
//                        self.presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Done")
//                    }
//                }
//            })
//        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct MetricDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MetricDetailView(metric: .heatStrain(value: 2))
    }
}

// MARK: Support Views
struct MetricDisplayView: View {
    
    // View Variables
    var iconName: String
    var iconColor: Color
    var header: String
    var subtext: String
    var extraPadding: Int = 0
    
    // View Body
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Current Status")
                .dynamicFont(.title3)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .symbolRenderingMode(.hierarchical)
                    .dynamicFont(.system(size: 80), padding: 0)
                    .padding(.leading, CGFloat(extraPadding))
                
                VStack(alignment: .leading) {
                    Text(header)
                        .fontWeight(.bold)
                        .dynamicFont(.title2, padding: 0)
                    
                    Text(subtext)
                        .fontWeight(.regular)
                        .dynamicFont(.headline, padding: 0)
                        .padding(.trailing, 5)
                }
                .padding(.leading, CGFloat(extraPadding))
                
                Spacer()
            }
            .padding(.top, 1)
        }
        .padding(.vertical)
        .modifier(RectangleWrapper(color: .secondary.opacity(0.10)))
        .padding(.horizontal)
    }
}
struct IconRowView: View {
    
    // View Variables
    var imageName: String
    var header: String
    var subtext: String
    
    // View Body
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(header)
                    .dynamicFont(.headline, padding: 0)
                
                Text(subtext)
                    .dynamicFont(.body, lineLimit: 2, padding: 0)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.leading)
    }
}
