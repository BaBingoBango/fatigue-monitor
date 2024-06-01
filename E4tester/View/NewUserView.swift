//
//  NewUserView.swift
//  E4tester
//
//  Created by Ethan Marshall on 5/30/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NewUserView: View {
    @EnvironmentObject var modelData: ModelData
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var age: String = ""
    @State var groupId: String = "";
    @State var startDate: Date = Date()
    @State var uploadDataOperation = Operation()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, -2)
                Text("Please tell us about yourself.")
                    .padding(.bottom, 24)
                
                FloatingLabelInput(label: "First Name", text: $firstName, numberPad: false, isSecure: false)
                FloatingLabelInput(label: "Last Name", text: $lastName, numberPad: false, isSecure: false)
                FloatingLabelInput(label: "Age", text: $age, numberPad: true, isSecure: false)
                FloatingLabelInput(label: "Group ID", text: $groupId, numberPad: false, isSecure: false)
                DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    .padding([.horizontal], 60)
                
                // continue button
                if !firstName.isEmpty && !lastName.isEmpty && !age.isEmpty && !groupId.isEmpty {
                    Spacer()
                        .frame(height: 24)
                    
                    switch uploadDataOperation.status {
                    case .notStarted:
                        Button(action: continueOnboarding) {
                            HStack {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                                    .imageScale(.medium)
                            }
                        }
                    case .inProgress:
                        ProgressView()
                    case .success:
                        ProgressView()
                    case .failure:
                        Button(action: continueOnboarding) {
                            HStack {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                                    .imageScale(.medium)
                            }
                        }
                        
                        Text(uploadDataOperation.errorMessage)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        try! Auth.auth().signOut()
                    }) {
                        Text("Sign Out")
                    }
                }
            })
        }
    }
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userStartDate") var userStartDate: Double = 0
    
    /// Finish onboarding
    func continueOnboarding() {
        uploadDataOperation.status = .inProgress
        
        userAge = Int(age) ?? 0
        if(userAge < 18) {
            Toast.showToast("You must be 18 or older to use this app.")
            uploadDataOperation.status = .failure
            return
        }
        
        UserDefaults.standard.setValue(7, forKey: "xAxisStartHour")
        
        userFirstName = firstName
        userStartDate = startDate.startOfDay.timeIntervalSince1970
        
        FirebaseManager.connect()
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).setData([
            "first_name": firstName,
            "last_name": lastName,
            "device_uuid": deviceId ?? "No Device ID Avaliable",
            "age": age,
            "group_id": groupId,
            "start_date": startDate.startOfDay.timeIntervalSince1970,
            // Heart rate stuff
            "heart_rate_reserve_cp": Int(20),
            "k_value": Int(15),
            "rest_heart_rate": Int(60),
            "total_awc": Int(150)
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                uploadDataOperation.setError(message: err.localizedDescription)
            } else {
                print("Document successfully written!")
                Toast.showToast("Welcome!")
                uploadDataOperation.status = .success
            }
        }
        FirebaseManager.subscribeToGroup(groupId: groupId)
    }
}
