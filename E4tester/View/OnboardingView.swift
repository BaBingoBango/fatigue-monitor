//
//  OnboardingView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/16/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI
import FirebaseAuth

/// Onboarding view, shown on first app launch after installation
struct OnboardingView: View {
    @EnvironmentObject var modelData: ModelData
    @State var enteredEmail = ""
    @State var enteredPassword = ""
    @State var signInOperation = Operation()
    
    @Binding var userOnboarded: Bool;
    
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, -2)
            Text("Please create an account. If you already have one, we'll sign you in.")
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
            
            FloatingLabelInput(label: "Email Address", text: $enteredEmail, numberPad: false, isSecure: false)
            FloatingLabelInput(label: "Password", text: $enteredPassword, numberPad: false, isSecure: true)
            
            // continue button
            if !enteredEmail.isEmpty && !enteredPassword.isEmpty {
                Spacer()
                    .frame(height: 24)
                
                switch signInOperation.status {
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
                    
                    Text(signInOperation.errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userStartDate") var userStartDate: Double = 0
    
    /// Finish onboarding
    func continueOnboarding() {
        signInOperation.status = .inProgress
        
        Auth.auth().signIn(withEmail: enteredEmail, password: enteredPassword) { authResult, error in
            if let error = error as NSError? {
                // Check if the error is due to the user not being found.
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    // User doesn't exist, create a new account.
                    Auth.auth().createUser(withEmail: enteredEmail, password: enteredPassword) { authResult, error in
                        if let error = error {
                            // There was an error creating the user.
                            signInOperation.setError(message: error.localizedDescription)
                        } else if let authResult = authResult {
                            // User created successfully.
                            signInOperation.status = .success
                        }
                    }
                } else {
                    // Sign in failed for another reason.
                    signInOperation.setError(message: error.localizedDescription)
                }
            } else if let authResult = authResult {
                // The user signed in successfully.
                signInOperation.status = .success
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(userOnboarded: .constant(false))
            .environmentObject(ModelData())
    }
}
