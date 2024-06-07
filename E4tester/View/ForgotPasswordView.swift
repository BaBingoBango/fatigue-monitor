//
//  ForgotPasswordView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/1/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI
import FirebaseAuth

/// A screen prompting users to reset their Firebase Auth account password.
struct ForgotPasswordView: View {
    
    // MARK: View Variables
    /// Whether or not this view is presented.
    @Environment(\.presentationMode) var presentationMode
    /// The email the user has entered on this screen.
    @State var enteredEmail: String
    /// The Firebase Auth password reset send action.
    @State var resetEmailSendOperation = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            VStack {
                Text("Forgot your password?")
                    .dynamicFont(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter your email address and we'll send you a password reset message.")
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                    .padding(.top, 5)
                
                FloatingLabelInput(label: "Email Address", text: $enteredEmail, numberPad: false, isSecure: false)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .disabled(resetEmailSendOperation.status == .success)
                
                switch resetEmailSendOperation.status {
                case .notStarted:
                    if !enteredEmail.isEmpty {
                        Button(action: {
                            sendResetEmail()
                        }) {
                            HStack {
                                Text("Continue")
                                
                                Image(systemName: "arrow.right")
                                    .imageScale(.medium)
                            }
                        }
                    }
                    
                case .inProgress:
                    ProgressView()
                    
                case .success:
                    Text("Password reset sent! Be sure to check your spam inbox.")
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                    
                case .failure:
                    if !enteredEmail.isEmpty {
                        Button(action: {
                            sendResetEmail()
                        }) {
                            HStack {
                                Text("Continue")
                                
                                Image(systemName: "arrow.right")
                                    .imageScale(.medium)
                            }
                        }
                    }
                    
                    Text(resetEmailSendOperation.errorMessage)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            })
        }
    }
    
    // MARK: View Functions
    func sendResetEmail() {
        resetEmailSendOperation.status = .inProgress
        
        Auth.auth().sendPasswordReset(withEmail: enteredEmail) { error in
            if let error = error {
                resetEmailSendOperation.setError(message: error.localizedDescription)
            } else {
                resetEmailSendOperation.status = .success
            }
        }
    }
}

// MARK: View Preview
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(enteredEmail: "")
    }
}
