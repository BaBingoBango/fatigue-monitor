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
            
            // List of peers
            HStack {
                Spacer()
                let sortedCrew = modelData.crew.sorted { (lhs: Peer, rhs: Peer) in
                    return lhs.first_name < rhs.first_name
                }
                ForEach(Array(sortedCrew.enumerated()), id: \.element) { index, peer in
                    Circle()
                        .fill(Color.getColor(withIndex: index))
                        .frame(width: 8, height: 8)
                    Text(peer.first_name)
                    Spacer()
                }
            }
            .font(.system(size: 16, weight: .medium))
            .transition(.moveAndFade)
            .frame(height: 15)
            .padding(.bottom, 5)
            
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
                VStack{
                    MultiLineChartView(peers: modelData.crew)
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
            .padding([.horizontal], 70)
        }
    }

    /// x-axis labels
    var LabelView: some View {
        Group {
            Spacer()
            HStack {
                Text("9am")
                Spacer()
                Text("11am")
                Spacer()
                Text("1pm")
                Spacer()
                Text("3pm")
                Spacer()
                Text("5pm")
            }
            Spacer()
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
            timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
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
