//
//  CrewChartView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/14/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI
import Charts

/// An app view written in SwiftUI!
struct CrewChartView: View {
    
    // MARK: View Variables
    var peers: [Peer]
    var metricType: MetricType
    
    // MARK: View Body
    var body: some View {
        ZStack {
            if metricType == .fatigue && !peers.isEmpty {
                ChartBackgroundView(chartScale: 100, desiredRangeStart: 10, desiredRangeEnd: 47.5, color: .green, yAxisLabelWidth: 35)
                ChartBackgroundView(chartScale: 100, desiredRangeStart: 47.5, desiredRangeEnd: 75, color: .orange, yAxisLabelWidth: 35)
                ChartBackgroundView(chartScale: 100, desiredRangeStart: 75, desiredRangeEnd: 100, color: .red, yAxisLabelWidth: 35)
                
            } else if !peers.isEmpty {
                ChartBackgroundView(chartScale: 10, desiredRangeStart: 0.99, desiredRangeEnd: 4.75, color: .green, yAxisLabelWidth: 35)
                ChartBackgroundView(chartScale: 10, desiredRangeStart: 4.75, desiredRangeEnd: 6.5, color: .orange, yAxisLabelWidth: 35)
                ChartBackgroundView(chartScale: 10, desiredRangeStart: 6.5, desiredRangeEnd: 10.25, color: .red, yAxisLabelWidth: 35)
            }
            
            Chart(metricType == .fatigue ? getFatigueDataset() : getHeatDataset()) {
                LineMark(
                    x: .value("Time", formatHourFromMidnight(hour: $0.hourFromMidnight)),
                    y: .value("Average Fatigue Level", $0.value)
                )
                .foregroundStyle(by: .value("First Name", $0.peerName))
                
                PointMark(
                    x: .value("Time", formatHourFromMidnight(hour: $0.hourFromMidnight)),
                    y: .value("Average Fatigue Level", $0.value)
                )
                .foregroundStyle(by: .value("First Name", $0.peerName))
            }
            .chartYAxis {
                if metricType == .fatigue {
                    AxisMarks(values: .stride(by: 20)) { value in
                        AxisValueLabel("\(value.as(Int.self) ?? 0)%")
                    }
                } else {
                    AxisMarks(values: .stride(by: 2)) { value in
                        AxisValueLabel("\(value.as(Int.self) ?? 0) PSI")
                    }
                }
            }
            .chartYScale(domain: metricType == .fatigue ? 0...100 : 0...10)
        }
        .frame(height: 300)
    }
    
    // MARK: View Functions
    func colorForPeer(_ peer: Peer) -> Color {
        let splitArray = CrewView.arraySplitter(sortedCrew: peers)
        for (eachOuterIndex, eachPeerArray) in splitArray.enumerated() {
            for (eachInnerIndex, eachPeer) in eachPeerArray.enumerated() {
                
                if eachPeer.id == peer.id {
                    return Color.getColor(withIndex: (eachOuterIndex * 3) + eachInnerIndex)
                }
            }
        }
        return .black
    }
    func formatHourFromMidnight(hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        if let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) {
            return formatter.string(from: date)
        }
        return "\(hour)"
    }
    func getFatigueDataset() -> [ChartDataPoint] {
        var answer: [ChartDataPoint] = []
        
        for eachPeer in peers {
            for eachFatigueObservation in eachPeer.observations {
                answer.append(.init(peerName: eachPeer.first_name,
                                    peerID: eachPeer.id.uuidString,
                                    hourFromMidnight: eachFatigueObservation.hour_from_midnight,
                                    value: eachFatigueObservation.avg_fatigue_level
                                   ))
            }
        }
        return answer
    }
    func getHeatDataset() -> [ChartDataPoint] {
        var answer: [ChartDataPoint] = []
        
        for eachPeer in peers {
            for eachHeatObservation in eachPeer.heatObservations {
                answer.append(.init(peerName: eachPeer.first_name,
                                    peerID: eachPeer.id.uuidString,
                                    hourFromMidnight: eachHeatObservation.hourFromMidnight,
                                    value: eachHeatObservation.averageHeatStrain
                                   ))
            }
        }
        return answer
    }
}

// MARK: View Preview
struct CrewChartView_Previews: PreviewProvider {
    static var previews: some View {
        CrewChartView(peers: getPreviewPeers(), metricType: .fatigue)
    }
}

// MARK: Support Views
struct ChartBackgroundView: View {
    var chartScale: Int
    var desiredRangeStart: Double
    var desiredRangeEnd: Double
    var color: Color
    let yAxisLabelWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let totalWidth = geometry.size.width - yAxisLabelWidth
            let rangeHeight = (desiredRangeEnd - desiredRangeStart) / Double(chartScale) * totalHeight
            let yOffset = (desiredRangeStart / Double(chartScale)) * totalHeight
            
            Rectangle()
                .fill(color.opacity(0.15))
                .frame(width: totalWidth, height: rangeHeight)
                .offset(y: totalHeight - yOffset - rangeHeight)
                .zIndex(-1)
                .allowsHitTesting(false)
        }
    }
}

// MARK: Support Structures
struct ChartDataPoint: Identifiable {
    var id = UUID()
    var peerName: String
    var peerID: String
    var hourFromMidnight: Int
    var value: Double
}
