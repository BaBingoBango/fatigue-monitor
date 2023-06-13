//
//  SettingsView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 6/13/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("receiveCrewReminders")
    var receiveErrorNotifications: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $receiveErrorNotifications) {
                        Text("TODO")
                    }
                }
                
                // App Info
                Section(header: Text("App Info")) {
                    NavigationLink("About SafeConnect") {
                        WebView(url: URL(string: "https://google.com"))
                    }
                    NavigationLink("Help & Support") {
                        WebView(url: URL(string: "https://google.com"))
                    }
                    NavigationLink("Legal") {
                        WebView(url: URL(string: "https://google.com"))
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

