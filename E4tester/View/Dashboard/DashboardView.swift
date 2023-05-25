//
//  DashboardView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Modified by Seung-Gu Lee on 5/16/23.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var modelData: ModelData
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @StateObject var groupMates = RegisteredUserArr()
    
    @State var dateSelection: Date = Date()
    
    // timer for periodic crew info retrieval
    @State var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView{
                
                    VStack(alignment: .leading) {
                        
                        Text("Daily Summary")
                            .font(.system(size: 20, weight: .bold))
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        HStack {
                            Image(systemName: "hand.wave.fill")
                            Text("Hello, \(userFirstName)")
                        }
                        .font(.system(size: 20, weight: .semibold))
                        .padding([.horizontal], 20)
                        
                        InfoView()
                            .frame(height: 200)
                            .background(DarkMode.isDarkMode() ? Color.black : Color.white)
                            .cornerRadius(15)
                            .padding([.horizontal], 20)
                        
                        // Highlights
                        VStack {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                Text("Highlights")
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding([.horizontal], 20)
                        }
                        .padding(.bottom, 8)
                    
                        HighlightView()
                            .padding([.horizontal], 20)
                            .frame(height: 120, alignment: .center)
                    
                        NavigationLink(destination: DummyView()) {
                            HStack {
                                Spacer()
                                Text("See all highlights")
                                Image(systemName: "arrow.right")
                                    .imageScale(.small)
                                Spacer()
                            }
                            .padding([.horizontal], 40)
                        }
                        .padding(.bottom, 30)
                    
                        // My Crew
                        VStack(alignment: .leading) {
                            // header
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("My Crew")
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding([.horizontal], 20)
                            
                            // graph
                            CrewView()
                                .padding([.horizontal], 20)
                                .onReceive(timer) { _ in
                                    updateCrew()
                                }
                                .onAppear {
                                    initCrew()
                                }
                            
                            // Date Selection
                            DatePicker("Date", selection: $dateSelection,
                                       displayedComponents: [.date])
                            .padding([.horizontal], 110)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .onChange(of: dateSelection, perform: { value in
                                updateCrew()
                            })
                        }
                    }
                }
                
                    
            }
        }
        .onAppear {
            getGroupmateNames()
        }
        
    }
    
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
    
    func initCrew() {
        getGroupmateNames()
        print("init crew")
        Task {
            modelData.updateCrew(dateSelection)
        }
    }
    
    @AppStorage("userGroupId") var userGroupId: String = ""
    func getGroupmateNames() {
        print("Group ID: \(userGroupId)")
        FirebaseManager.connect()
        FirebaseManager.getUsersInGroup(groupId: userGroupId, userArr: groupMates)
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ModelData())
    }
}
