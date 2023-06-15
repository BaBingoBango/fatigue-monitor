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
        Form {
            Section(header: Text("Notifications")) {
                Toggle(isOn: $receiveErrorNotifications) {
                    Text("TODO")
                }
            }
            
            // App Info
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            Section(header: Text("App Info"),
                    footer: Text("Version " + (appVersion ?? "?"))) {
                NavigationLink("About SafeConnect") {
                    WebView(url: URL(string: "https://google.com"))
                }
                NavigationLink("Help & Support") {
                    WebView(url: URL(string: "https://google.com"))
                }
                NavigationLink("Privacy Policy") {
                    WebView(url: URL(string: "https://google.com"))
                }
            }
            
            // App Info
            Section(header: Text("Testing")) {
                Button("Test Push Notification") {
                    NodeServer.sendFatigueWarning(firstName: "Test Name",
                                                  fatigueLevel: 55,
                                                  groupId: "2")
                }
            }
        }
    }
}

