//
//  EMASurveyView.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/4/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

/// The data collection view for EMA surveys.
struct EMASurveyView: View {
    
    // MARK: View Variables
    /// Whether or not this view is presented.
    @Environment(\.presentationMode) var presentationMode
    /// Whether or not the cancellation confirmation prompt is being presented.
    @State var isShowingCancellationAlert = false
    /// The response for question 1 of the survey.
    @State var question1Response: Bool? = nil
    /// The response for question 2 of the survey.
    @State var question2Response: Bool? = nil
    /// The status of the survey submission.
    @State var submitSurveyOperation = Operation()
    var shouldDisableSubmitButton: Bool {
        question1Response == nil || question2Response == nil || submitSurveyOperation.status == .inProgress
    }
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        QuestionView(question: "Since the last survey, have you assisted your crew members to make sure they performed their work safely?",
                                     response: $question1Response,
                                     shouldDisableQuestionControls: submitSurveyOperation.status == .inProgress
                        )
                        .padding(.top)
                        
                        QuestionView(question: "Since the last survey, have you taken action to protect your crew members from safety hazards or risky situations?",
                                     response: $question2Response,
                                     shouldDisableQuestionControls: submitSurveyOperation.status == .inProgress
                        )
                        .padding(.top)
                    }
                }
                
                Group {
                    if submitSurveyOperation.status != .inProgress {
                        Button(action: {
                            submitSurvey()
                        }) {
                            Text("Submit Survey")
                        }
                    } else {
                        ProgressView()
                    }
                }
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .modifier(RectangleWrapper(fixedHeight: 60, color: !shouldDisableSubmitButton ? .blue : .secondary))
                    .opacity(!shouldDisableSubmitButton ? 1 : 0.75)
                    .padding()
                    .disabled(shouldDisableSubmitButton)
            }
                .navigationTitle("EMA Survey")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            isShowingCancellationAlert = true
                        }) {
                            Text("Exit")
                        }
                        .disabled(submitSurveyOperation.status == .inProgress)
                        .alert(isPresented: $isShowingCancellationAlert) {
                            Alert(title: Text("Are you sure you want to exit this survey?"),
                                  message: Text("We ask that you complete the survey three times a day."),
                                  primaryButton: .default(Text("Continue")),
                                  secondaryButton: .destructive(Text("Exit"), action: { self.presentationMode.wrappedValue.dismiss() })
                            )
                        }
                    }
                })
        }
        .interactiveDismissDisabled()
    }
    
    // MARK: View Functions
    func submitSurvey() {
        submitSurveyOperation.status = .inProgress
        let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970)
        
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            .collection("ema_surveys").document(docName).setData([
                "question1_response": question1Response!,
                "question2_response": question2Response!
        ]) { error in
            if let error = error {
                submitSurveyOperation.setError(message: error.localizedDescription)
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: View Preview
struct EMASurveyView_Previews: PreviewProvider {
    static var previews: some View {
        EMASurveyView()
    }
}

// MARK: Support Views
struct QuestionView: View {
    
    // View Variables
    var question: String
    @Binding var response: Bool?
    var shouldDisableQuestionControls: Bool
    
    // View Body
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            
            VStack {
                Text(question)
                    .padding()
                
                Divider()
                
                Button(action: {
                    response = true
                }) {
                    HStack {
                        Image(systemName: response != nil && response! ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!shouldDisableQuestionControls ? .blue : .gray)
                            .dynamicFont(.title2, padding: 0)
                        
                        Text("Yes")
                            .foregroundColor(.primary)
                            .dynamicFont(.title3, padding: 0)
                        
                        Spacer()
                    }
                }
                .disabled(shouldDisableQuestionControls)
                .padding(.leading)
                .padding(.top, 5)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
                Button(action: {
                    response = false
                }) {
                    HStack {
                        Image(systemName: response != nil && !response! ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(!shouldDisableQuestionControls ? .blue : .secondary)
                            .dynamicFont(.title2, padding: 0)
                        
                        Text("No")
                            .foregroundColor(.primary)
                            .dynamicFont(.title3, padding: 0)
                        
                        Spacer()
                    }
                }
                .disabled(shouldDisableQuestionControls)
                .padding([.leading, .bottom])
            }
        }
        .cornerRadius(10)
        .shadow(radius: 7)
        .padding(.horizontal)
    }
}
