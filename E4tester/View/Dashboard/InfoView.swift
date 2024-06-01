//
//  InfoView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/13/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

/// Displays heart rate and fatigue level.
struct InfoView: View {
    
    // MARK: View Variables
    @EnvironmentObject var modelData: ModelData
    @State var animationBool: Bool = false
    let heatStrainLevel = HeatStrainLevel.high
    
    // MARK: View Body
    var body: some View {
        HStack {
            // Heart Rate
            ZStack {
                // background
                Circle()
                    .fill(DarkMode.isDarkMode() ? Color(white: 0.08) : .white)
                    .shadow(radius: 3)
                
                // rotating animation
                if modelData.deviceConnected { // if device connected
                    Circle()
                        .trim(from: 0, to: 0.2)
                        .stroke(Color.red, lineWidth: 2)
                        .rotationEffect(Angle(degrees: animationBool ? 360 : 0))
                        .animation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false))
                        .onAppear {
                            animationBool = true
                        }
                }
                
                VStack {
                    VStack {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .imageScale(.small)
                                .dynamicFont(.callout, padding :0)
                                .foregroundColor(.secondary)
                            
                            Text("BPM")
                                .dynamicFont(.callout, padding :0)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(self.modelData.heartRate == 0 ? "--" : "\(self.modelData.heartRate)")
                            .dynamicFont(.title, padding: 0)
                            .fontWeight(.bold)
                    }
                    
                    if modelData.lastUpdatedTime != "-" {
                        Text("as of \(modelData.lastUpdatedTime)")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Color(white: 0.5))
                    }
                    else {
                        if modelData.deviceConnected {
                            Text("Collecting")
                                .dynamicFont(.footnote, padding: 20)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                        } else {
                            Text("Disconnected")
                                .dynamicFont(.footnote, padding: 20)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .multilineTextAlignment(.center)
            }
            .padding([.leading], 10)
            
            // Fatigue Level
            ZStack {
                // background
                Circle()
                    .fill(DarkMode.isDarkMode() ? Color(white: 0.08) : .white)
                    .shadow(radius: 3)
                
                // fatigue level text
                VStack (spacing: 0) {
                    Text("FATIGUE")
                        .dynamicFont(.callout, padding :0)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 1) {
                        if self.modelData.fatigueLevel >= 0 {
                            Text("%")
                                .dynamicFont(.caption2, padding: 0)
                                .hidden()
                        }
                        
                        Text(self.modelData.fatigueLevel < 0 ? "--" : self.fatigueLevelDisplay(fatigueLevel: self.modelData.fatigueLevel))
                            .dynamicFont(.title, padding: 0)
                            .fontWeight(.bold)
                        
                        if self.modelData.fatigueLevel >= 0 {
                            Text("%")
                                .dynamicFont(.title3, padding: 0)
                        }
                    }
                    
                    if self.modelData.fatigueLevel < 40  {
                        HStack(spacing: 0) {
                            Image(systemName: "checkmark.shield.fill")
                                .imageScale(.small)
                            
                            Text("Low")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(red: 10/255, green: 163/255, blue: 0))
                    }
                    else if self.modelData.fatigueLevel < 70 {
                        HStack(spacing: 0) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .imageScale(.small)
                            
                            Text("Moderate")
                                .dynamicFont(.callout, padding: 0)
                        }
                        .foregroundColor(.orange)
                    }
                    else if self.modelData.fatigueLevel < 90 {
                        HStack(spacing: 0) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .imageScale(.small)
                            
                            Text("High")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.red)
                    }
                    else {
                        HStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .imageScale(.small)
                            Text("Critical")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.red)
                    }
                }
                .multilineTextAlignment(.center)
                
            }
            .padding([.trailing, .leading], 5)
            
            // MARK: - dupe view here
            ZStack {
                Circle()
                    .fill(DarkMode.isDarkMode() ? Color(white: 0.08) : .white)
                    .shadow(radius: 3)
                
                VStack(spacing: 4) {
                    Text("HEAT")
                        .dynamicFont(.callout)
                        .foregroundColor(.secondary)
                    
                    switch heatStrainLevel {
                    case .unknown:
                        Text("--")
                            .dynamicFont(.title)
                            .fontWeight(.bold)
                        
                        Text("Unknown")
                            .dynamicFont(.footnote, padding: 0)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        
                    case .low:
                        Image(systemName: "checkmark.shield.fill")
                            .dynamicFont(.title2)
                            .foregroundColor(Color(red: 10/255, green: 163/255, blue: 0))
                        
                        Text("Low")
                            .dynamicFont(.footnote, padding: 0)
                            .foregroundColor(Color(red: 10/255, green: 163/255, blue: 0))
                            .fontWeight(.semibold)
                        
                    case .moderate:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .dynamicFont(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Moderate")
                            .dynamicFont(.footnote, padding: 0)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                        
                    case .high:
                        Image(systemName: "exclamationmark.octagon.fill")
                            .dynamicFont(.title2)
                            .foregroundColor(.red)
                        
                        Text("High")
                            .dynamicFont(.footnote, padding: 0)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                }
                .multilineTextAlignment(.center)
                
            }
            .padding([.trailing], 10)
        }
    }

    func fatigueLevelDisplay(fatigueLevel: Int) -> String {
        if (fatigueLevel > 100) {
            return "100"
        }
        return String(fatigueLevel)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(ModelData())
    }
}
