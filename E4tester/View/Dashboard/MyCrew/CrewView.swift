//
//  CrewView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct CrewView: View {
    @EnvironmentObject var modelData: ModelData
    @State var dateSelection: Date = Date()
    @ObservedObject var groupMates = RegisteredUserArr()
    @State var selectedMetricType: MetricType = .fatigue
    
    @State var toggleToRefresh: Bool = false
    
    // timer for periodic crew info retrieval
    @State var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedMetricType) {
                Text("Fatigue").tag(MetricType.fatigue)
                Text("Heat Strain").tag(MetricType.heatStrain)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 5)
            
            HStack {
                VStack {
                    let sortedPreviewCrew = getPreviewPeers().sorted { (lhs: Peer, rhs: Peer) in
                        return lhs.first_name < rhs.first_name
                    }
                    let sortedCrew = modelData.crew.sorted { (lhs: Peer, rhs: Peer) in
                        return lhs.first_name < rhs.first_name
                    }
                    
                    CrewChartView(peers: selectedMetricType == .fatigue ? sortedCrew : sortedPreviewCrew, metricType: selectedMetricType)
                }
            }
            .onAppear {
                getGroupmateNames()
                initCrew()
            }
            .onReceive(timer) { _ in
                updateCrew()
            }
            
            // Date Selection
            HStack {
                DatePicker("Date", selection: $dateSelection,
                           displayedComponents: [.date])
                .onChange(of: dateSelection, perform: { value in
                    updateCrew()
                })
                
                Button(action: {
                    dateSelection = Date().startOfDay
                    toggleToRefresh.toggle()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .padding(.leading, 8)
            }
            .padding(.top)
            .padding(.bottom, 16)
            .padding([.horizontal], 60)
        }
    }

    /// x-axis labels
    var LabelView: some View {
        Group {
            Spacer()
            HStack {
                let lowerBound = UserDefaults.standard.integer(forKey: "xAxisStartHour")
                ForEach(0..<5) { index in
                    Text(hrToString(lowerBound + (index * 2)))
                    if index < 4 {
                        Spacer()
                    }
                }
            }
            Spacer()
        }
    }
    
    public static func arraySplitter(sortedCrew: [Peer], num: Int = 3) -> ([[Peer]]) {
        var arr: [[Peer]] = []
        var temp: [Peer] = []
        var index: Int = 0
        
        while index < sortedCrew.count {
            if temp.count >= num {
                arr.append(temp);
                temp = []
            }
            temp.append(sortedCrew[index])
            index += 1
        }
        
        if !temp.isEmpty {
            arr.append(temp);
        }
        
        return arr
    }
    
    func hrToString(_ hr: Int) -> String {
        if hr == 0 {
            return "12am"
        }
        else if hr < 12 {
            return "\(hr)am"
        }
        else if hr == 12 {
            return "12pm"
        }
        else {
            return "\(hr-12)pm"
        }
    }
    
    /// Updates graph data on call
    func updateCrew() {
        getGroupmateNames()
        print("update crew")
        Task {
            modelData.updateCrew(dateSelection)
        }
        if !modelData.crew.isEmpty {
            timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
        }
    }
    
    /// Initializes graph data on call
    func initCrew() {
        getGroupmateNames()
        print("init crew")
        Task {
            modelData.updateCrew(dateSelection)
        }
    }
    
    /// Retrieves up-to-date groupmate names from the database
    @AppStorage("userGroupId") var userGroupId: String = ""
    func getGroupmateNames() {
        print("Group ID: \(userGroupId)")
        FirebaseManager.connect()
        FirebaseManager.getUsersInGroup(groupId: userGroupId, userArr: groupMates)
    }
}


struct CrewView_Previews: PreviewProvider {
    static var previews: some View {
        CrewView()
            .environmentObject(ModelData())
    }
}
