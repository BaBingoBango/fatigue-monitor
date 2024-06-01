//
//  ContentView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/18/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userChecker: UserExistenceChecker
    @EnvironmentObject var modelData: ModelData
    @State private var selection: Tab = .dashboard
    
    enum Tab {
        case dashboard
        case profile
        case device
        case survey
    }

    
    var body: some View {
        if userChecker.userExists {
            TabView(selection: $selection) {
                DashboardView(tabSelection: $selection)
                    .tabItem {
                        Label("Dashboard", systemImage: "heart.text.square")
                    }
                    .tag(Tab.dashboard)
                DeviceView()
                    .tabItem {
                        Label("Device", systemImage: "applewatch")
                    }
                    .tag(Tab.device)
                SurveyInfoView()
                    .tabItem {
                        Label("Survey", systemImage: "checkmark.square.fill")
                    }
                    .tag(Tab.survey)
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(Tab.profile)
            }
            .onAppear {
                FirebaseManager.connect()
                FirebaseManager.getUserGroupId()
            }
        } else {
            NewUserView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userChecker: .init(uid: "12345"))
            .environmentObject(ModelData())
    }
}
