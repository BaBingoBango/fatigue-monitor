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
    @EnvironmentObject var modelData: ModelData
    
    @State var animationBool: Bool = false
    
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
                    // BPM text
                    HStack {
                        Text(self.modelData.heartRate == 0 ? "--" : "\(self.modelData.heartRate)")
                            .font(.system(size: 64, weight: .heavy))
                            .scaledToFill()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .frame(width: 80, height: 55, alignment: .trailing)
                            .offset(x: 4, y: 0)
                        
                        VStack{
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("BPM")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    
                    // Status text
                    if modelData.lastUpdatedTime != "-" {
                        Text("as of \(modelData.lastUpdatedTime)")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Color(white: 0.5))
                    }
                    else {
                        if modelData.deviceConnected {
                            Text("Collecting data")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Color(white: 0.5))
                        }
                        else {
                            Text("Disconnected")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(Color(white: 0.5))
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
                VStack (spacing: 0){
                    HStack(alignment: .bottom, spacing: 3){
                        Text(self.modelData.fatigueLevel < 0 ? "--" : self.fatigueLevelDisplay(fatigueLevel: self.modelData.fatigueLevel))
                            .font(.system(size: 60, weight: .heavy))
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .frame(width: 80, height: 55, alignment: .trailing)
                            .offset(x: 4, y: 0)
                        Text("%")
                            .font(.system(size: 20, weight: .semibold))
                            .offset(x: 0, y: -3)
                        
                    }
                    Text("Fatigue Level")
                        .font(.system(size: 15, weight: .semibold))
                    
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
