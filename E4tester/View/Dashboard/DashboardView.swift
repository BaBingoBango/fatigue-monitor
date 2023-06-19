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
    
    /// Saved data
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userGroupId") var userGroupId: String = ""
    @ObservedObject var groupMates = RegisteredUserArr()
    
    @State var toggleToRefresh: Bool = false
    
    @Binding var tabSelection: ContentView.Tab

    var body: some View {
        GeometryReader { metrics in
            NavigationView {
                ZStack {
                    ScrollView {
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
                            
                            VStack(alignment: .center) {
                                HighlightView(tabSelection: $tabSelection)
                                    .padding([.horizontal], 20)
                                    .frame(height: 120, alignment: .center)
                            }
                            .frame(width: metrics.size.width, height: 120)
                            
                            NavigationLink(destination: FullscreenHighlightView(tabSelection: $tabSelection)) {
                                HStack {
                                    Spacer()
                                    Text("See all highlights")
                                        .font(.system(size: 15))
                                    Image(systemName: "arrow.right")
                                        .imageScale(.small)
                                    Spacer()
                                }
                                .padding([.horizontal], 40)
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 16)
                            
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
                            }
                        }
                    } // ScrollView
                } // ZStack
            } // NavigationView
            .onAppear {
                // getGroupmateNames()
            }
        } // GeometryReader
    }
    
    
    /// Retrieves up-to-date groupmate names.
    func getGroupmateNames() {
        print("Group ID: \(userGroupId)")
        FirebaseManager.connect()
        FirebaseManager.getUsersInGroup(groupId: userGroupId, userArr: groupMates)
    }
    
}
