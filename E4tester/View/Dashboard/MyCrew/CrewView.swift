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
    
    @State var toggleToRefresh: Bool = false
    
    // timer for periodic crew info retrieval
    @State var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            
            let sortedCrew = modelData.crew.sorted { (lhs: Peer, rhs: Peer) in
                return lhs.first_name < rhs.first_name
            }
            
            // List of peers
            let splittedArray = arraySplitter(sortedCrew: sortedCrew)
            VStack(alignment: .center) {
                
                ForEach(Array(splittedArray.enumerated()), id: \.element) { index1, arr in
                    HStack {
                        Spacer()
                        ForEach(Array(arr.enumerated()), id: \.element) { index, peer in
                            
                            HStack {
                                Spacer()
                                    .frame(maxWidth: 8)
                                Circle()
                                    .fill(Color.getColor(withIndex: (index1 * 3) + index))
                                    .frame(width: 8, height: 8)
                                Text(peer.first_name)
                                Spacer()
                                    .frame(maxWidth: 8)
                            }
                            
                        }
                        Spacer()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .transition(.moveAndFade)
                    .frame(height: 15)
                    .padding(.bottom, 5)
                }
            }

//            HStack {
//                Spacer()
//                ForEach(Array(sortedCrew.enumerated()), id: \.element) { index, peer in
//                    HStack {
//                        Circle()
//                            .fill(Color.getColor(withIndex: index))
//                            .frame(width: 8, height: 8)
//                        Text(peer.first_name)
//                        Spacer()
//                    }
//
//                }
//            }
//            .font(.system(size: 16, weight: .medium))
//            .transition(.moveAndFade)
//            .frame(height: 15)
//            .padding(.bottom, 5)
            
            
            
            // Graph
            HStack {
                Text("Average Fatigue Level")
                    .rotationEffect(.degrees(270))
                    .fixedSize()
                    .frame(width: 10, height: 90)
                    .font(.system(size: 16))
                
                // y-axis label
                VStack {
                    Text("100%")
                    Spacer()
                    Text("75%")
                    Spacer()
                    Text("50%")
                    Spacer()
                    Text("25%")
                    Spacer()
                    Text("0%")
                    HStack{
                        Text("")
                    }
                }
                VStack {
                    let sortedCrew = modelData.crew.sorted { (lhs: Peer, rhs: Peer) in
                        return lhs.first_name < rhs.first_name
                    }
                    MultiLineChartView(peers: sortedCrew)
                        .frame(height: 280)
                    HStack() {
                        LabelView // x-axis label
                    }
                    
                }
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .transition(.moveAndFade)
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
            .padding(.top, 8)
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
    
    func arraySplitter(sortedCrew: [Peer], num: Int = 3) -> ([[Peer]]) {
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
