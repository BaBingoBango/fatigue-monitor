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
    @State var isShowingFatigueDetail = false
    @State var isShowingHeatStrainDetail = false
    @State var BPMtextOpacity = 1.0
    @State var isBPMtextOpacityIncreasing = false
    @State var isAnimatingHeart = false
    let BPMtextOpacityTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    
    // MARK: View Body
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingFatigueDetail = true
                }) {
                    MetricWidgetView(
                        title: "Fatigue",
                        numberString: modelData.fatigueLevel >= 0 ? String(modelData.fatigueLevel) : "--",
                        unitString: modelData.fatigueLevel >= 0 ? "%" : "",
                        severity: {
                            if modelData.fatigueLevel < 0 {
                                return ""
                            } else if modelData.fatigueLevel < 40 {
                                return "Low Risk"
                            } else if modelData.fatigueLevel < 70 {
                                return "Moderate Risk"
                            } else if modelData.fatigueLevel < 90 {
                                return "High Risk"
                            } else {
                                return "Critical Risk"
                            }
                        }(),
                        color: {
                            if modelData.fatigueLevel < 0 {
                                return .secondary
                            } else if modelData.fatigueLevel < 40 {
                                return .green
                            } else if modelData.fatigueLevel < 70 {
                                return .orange
                            } else if modelData.fatigueLevel < 90 {
                                return .red
                            } else {
                                return .red
                            }
                        }()
                    )
                }
                .sheet(isPresented: $isShowingFatigueDetail) {
                    MetricsDetailView(fatigue: modelData.fatigueLevel, heatStrain: modelData.fatigueLevel, selectedMetric: .fatigue)
                }
                
                Button(action: {
                    isShowingHeatStrainDetail = true
                }) {
                    MetricWidgetView(
                        title: "Heat Strain",
                        numberString: modelData.fatigueLevel >= 0 ? String(modelData.fatigueLevel) : "--",
                        unitString: modelData.fatigueLevel >= 0 ? "PSI" : "",
                        severity: {
                            if modelData.fatigueLevel < 0 {
                                return ""
                            } else if modelData.fatigueLevel < 40 {
                                return "Low Risk"
                            } else if modelData.fatigueLevel < 70 {
                                return "Moderate Risk"
                            } else if modelData.fatigueLevel < 90 {
                                return "High Risk"
                            } else {
                                return "Critical Risk"
                            }
                        }(),
                        color: {
                            if modelData.fatigueLevel < 0 {
                                return .secondary
                            } else if modelData.fatigueLevel < 40 {
                                return .green
                            } else if modelData.fatigueLevel < 70 {
                                return .orange
                            } else if modelData.fatigueLevel < 90 {
                                return .red
                            } else {
                                return .red
                            }
                        }()
                    )
                }
                .sheet(isPresented: $isShowingHeatStrainDetail) {
                    MetricsDetailView(fatigue: modelData.fatigueLevel, heatStrain: modelData.fatigueLevel, selectedMetric: .heatStrain)
                }
            }
            
            HStack(spacing: 5) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(modelData.deviceConnected ? .red : .secondary)
                    .dynamicFont(.title, padding: 0)
                
                HStack(alignment: .bottom, spacing: 3) {
                    Text(self.modelData.heartRate == 0 ? "--" : "\(self.modelData.heartRate)")
                        .foregroundStyle(modelData.deviceConnected ? .red : .secondary)
                        .fontWeight(.bold)
                        .dynamicFont(.title, fontDesign: .rounded, padding: 0)
                    
                    Text(self.modelData.heartRate == 0 ? "" : "BPM")
                        .foregroundStyle(modelData.deviceConnected ? .red : .secondary)
                        .fontWeight(.bold)
                        .dynamicFont(.title3, fontDesign: .rounded, padding: 0)
                        .padding(.bottom, 2)
                }
                
                Spacer()
                
                Text({
                    if modelData.lastUpdatedTime != "-" {
                        return "as of \(modelData.lastUpdatedTime)"
                    } else if modelData.deviceConnected {
                        return "Collecting"
                    } else {
                        return "Disconnected"
                    }
                }())
                .foregroundStyle(modelData.heartRate == 0 && modelData.deviceConnected ? .red:  .secondary)
                    .fontWeight(.bold)
                    .dynamicFont(.subheadline, padding: 0)
                    .opacity(modelData.heartRate == 0 && modelData.deviceConnected ? BPMtextOpacity : 1)
                    .onReceive(BPMtextOpacityTimer) { input in
                        if isBPMtextOpacityIncreasing {
                            if BPMtextOpacity >= 1 {
                                isBPMtextOpacityIncreasing = false
                                BPMtextOpacity = BPMtextOpacity - 0.01
                            } else {
                                BPMtextOpacity = BPMtextOpacity + 0.01
                            }
                            
                        } else {
                            if BPMtextOpacity <= 0 {
                                isBPMtextOpacityIncreasing = true
                                BPMtextOpacity = BPMtextOpacity + 0.01
                            } else {
                                BPMtextOpacity = BPMtextOpacity - 0.01
                            }
                        }
                    }
            }
            .padding()
            .modifier(RectangleWrapper(color: .secondary.opacity(0.10)))
            .padding(.bottom)
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
