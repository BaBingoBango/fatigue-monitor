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
    var receiveCrewReminders: Bool = true
    
    @State var startDate: Date = Date()
    @State var age: Int = 0
    
    @State var x: Bool = false
    
    @State var showCompletedAlert: Bool = false

    
    var body: some View {
        Form {
//            Section(header: Text("Notifications")) {
//                Toggle(isOn: $receiveCrewReminders) {
//                    Text("Crew Reminders (12 PM, 3 PM)")
//                }
//                Toggle(isOn: $receiveCrewReminders) {
//                    Text("Hazard Warnings")
//                }
//            }
            
            // Profile
            Section(header: Text("Edit Profile"),
                    footer: Text("Please reinstall the app or contact the administrator to change your group ID.")) {
                
                LabeledContent {
                    TextField("##", value: $age, format: .number)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 12)
                } label: {
                    Text("Age")
                }
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                
                Button(action: editProfile) {
                    Text("Submit Changes")
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
            
            
            
            // Testing
            Section(header: Text("Testing")) {
                Button("Test Push Notification") {
                    NodeServer.sendFatigueWarning(firstName: "Test Name",
                                                  fatigueLevel: 55,
                                                  groupId: UserDefaults.standard.string(forKey: "userGroupId") ?? "")
                }
            }
            
            
        }
        .navigationTitle(Text("Settings"))
        .onAppear {
            startDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "userStartDate"))
            age = UserDefaults.standard.integer(forKey: "userAge")
        }
        // Alert Popup
        .alert("Submitted", isPresented: $showCompletedAlert, actions: {
            Button("Close", role: nil, action: {
                showCompletedAlert = false
            })
        }, message: {
            Text("Profile edited! Please note that some changes may require an app restart.")
        })
    }
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userStartDate") var userStartDate: Double = 0
    func editProfile() {
        userAge = Int(age) ?? 0
        userStartDate = startDate.startOfDay.timeIntervalSince1970
        if(userAge < 18) {
            Toast.showToast("You must be 18 or older to use this app.")
            return
        }
        
        FirebaseManager.connect()
        FirebaseManager.editUser(age: userAge, startDate: startDate)
        
        showCompletedAlert = true
    }
}

