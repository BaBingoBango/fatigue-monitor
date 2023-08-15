//
//  OnboardingView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/16/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI

/// Onboarding view, shown on first app launch after installation
struct OnboardingView: View {
    @EnvironmentObject var modelData: ModelData
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var age: String = ""
    @State var groupId: String = "";
    @State var startDate: Date = Date()
    
    @Binding var userOnboarded: Bool;
    
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, -2)
            Text("Please tell us about yourself.")
                .padding(.bottom, 24)
            
            FloatingLabelInput(label: "First Name", text: $firstName, numberPad: false)
            FloatingLabelInput(label: "Last Name", text: $lastName, numberPad: false)
            FloatingLabelInput(label: "Age", text: $age, numberPad: true)
            FloatingLabelInput(label: "Group ID", text: $groupId, numberPad: false)
            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                .padding([.horizontal], 60)
            
            // continue button
            if !firstName.isEmpty && !lastName.isEmpty && !age.isEmpty && !groupId.isEmpty {
                Spacer()
                    .frame(height: 24)
                Button(action: continueOnboarding) {
                    HStack {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userStartDate") var userStartDate: Double = 0
    
    /// Finish onboarding
    func continueOnboarding() {
        userAge = Int(age) ?? 0
        if(userAge < 18) {
            Toast.showToast("You must be 18 or older to use this app.")
            return
        }
        
        UserDefaults.standard.setValue(7, forKey: "xAxisStartHour")
        
        userOnboarded = true
        userFirstName = firstName
        userStartDate = startDate.startOfDay.timeIntervalSince1970
        
        Toast.showToast("Welcome!")
        
        FirebaseManager.connect()
        FirebaseManager.registerUser(firstName: firstName, lastName: lastName,
                                     age: userAge, groupId: groupId, startDate: startDate)
        FirebaseManager.subscribeToGroup(groupId: groupId)
    }
}
