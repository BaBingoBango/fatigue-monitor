//
//  FriendsView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI
import SkeletonUI

struct ProfileView: View {
    @EnvironmentObject var modelData: ModelData
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userGroupId") var userGroupId: String = ""
    
    @StateObject var groupMates = RegisteredUserArr()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    // User information
                    HStack {
                        // User info
                        VStack {
                            Text("\(userFirstName)")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.bottom, -4)
                                .padding(.top, 10)
                            
                            Text("Age: \(userAge)")
                                .font(.system(size: 12))
                                .padding(.bottom, 8)
                        }
                        .frame(width: 150)
                        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                        .cornerRadius(16)
                        .padding(.trailing, 12)
                        
                        // Group members
                        VStack {
                            Text("Group \(userGroupId)")
                                .font(.system(size: 18, weight: .bold))
                                .padding(.bottom, -1)
                                .padding(.top, 10)
                            
                            Rectangle()
                                .frame(width: 150, height: 1)
                                .foregroundColor(DarkMode.isDarkMode() ? Color(white: 0.7) : Color(white: 0.3))
                            
                            
                            let groupmateNames = groupMates.getUserFullNames()
                            
                            // Loading from Firebase
                            if groupmateNames.isEmpty {
                                Text("Loading...")
                                    .skeleton(with: true,
                                              size: CGSize(width: 180, height: 16))
                                Text("Loading...")
                                    .skeleton(with: true,
                                              size: CGSize(width: 180, height: 16))
                                Text("Loading...")
                                    .skeleton(with: true,
                                              size: CGSize(width: 180, height: 16))
                            }
                            else {
                                // Group member names
                                ForEach(groupmateNames.indices, id: \.self) { index in
                                    Text(groupmateNames[index])
                                }
                            }
                            
                            
                            Spacer()
                                .frame(height: 12)
                        }
                        .frame(width: 200)
                        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                        .cornerRadius(16)
                        .onAppear {
                            getGroupmateNames()
                        }
                    } // HStack
                    
                    // Timeline
                    TimelineView()
                        .padding(.top, 32)
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .padding([.vertical], 8)
                    }
                } // VStack
            } // ScrollView
            .navigationTitle(Text("Profile"))
        } // NavigationView
        
    }
    
    
    
    func getGroupmateNames() {
        print("Group ID: \(userGroupId)")
        FirebaseManager.connect()
        FirebaseManager.getUsersInGroup(groupId: userGroupId, userArr: groupMates)
    }
    
}
