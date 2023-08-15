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
    
    @AppStorage("xAxisStartHour")
    var xAxisStartHour: Int = 7
    
    @State var x: Bool = false
    
    @State var showCompletedAlert: Bool = false

    
    var body: some View {
        Form {
            // Profile
            Section(header: Text("Edit Profile"),
                    footer: Text("Please reinstall the app or contact the administrator to change your group ID.")) {
                
                Picker("Age", selection: $age) {
                    ForEach(15..<150) { index in
                        Text("\(index)").tag(index)
                    }
                }
                .onAppear {
                    startDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "userStartDate"))
                    age = UserDefaults.standard.integer(forKey: "userAge")
                }
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                
                Button(action: editProfile) {
                    Text("Save Changes")
                }
            }
            
            // Graph
            Section(header: Text("Graph")) {
                Picker("X-axis Range", selection: $xAxisStartHour) {
                    Group {
                        Text("2am - 10am").tag(2)
                        Text("3am - 11am").tag(3)
                        Text("4am - 12pm").tag(4)
                        Text("5am - 1pm").tag(5)
                        Text("6am - 2pm").tag(6)
                        Text("7am - 3pm").tag(7)
                    }
                    Group {
                        Text("8am - 4pm").tag(8)
                        Text("9am - 5pm").tag(9)
                        Text("10am - 6pm").tag(10)
                        Text("11am - 7pm").tag(11)
                        Text("12pm - 8pm").tag(12)
                        Text("1pm - 9pm").tag(13)
                        Text("2pm - 10pm").tag(14)
                        Text("3pm - 11pm").tag(15)
                    }
                }
            }
            
            // App Info
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            Section(header: Text("App Info"),
                    footer: Text("Version " + (appVersion ?? "?"))) {
                NavigationLink("About SafeConnect") {
                    WebView(url: URL(string: "https://google.com"))
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("Help & Support") {
                    WebView(url: URL(string: "https://google.com"))
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("Privacy Policy") {
                    WebView(url: URL(string: "https://google.com"))
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("E4 Wristband User Manual") {
                    WebView(url: URL(string: "https://eu32.salesforce.com/sfc/p/#5J000001QPsT/a/5J000000p2rz/7eFMC1dLiJPyeTNeTgkxHFOFcdN77YXxiHijMSHsz6E"))
                        .navigationBarTitleDisplayMode(.inline)
                }
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }) {
                    Text("App Settings")
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

