//
//  ContentView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/18/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    @State private var selection: Tab = .dashboard
    
    enum Tab {
        case dashboard
        case profile
        case device
        case survey
    }

    
    var body: some View {
//        if modelData.loggedIn {
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
//        } else if !modelData.nameEntered {
//            LoginView()
//        } else {
//            LoginDetailView()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
