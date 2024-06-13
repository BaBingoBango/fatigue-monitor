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
    /// The status of the survey check (has the user submitted yet today?).
    @State var surveyCheckOperation = Operation(status: .inProgress)
    /// Whether or not this is the user's first survey of the day,
    @State var isFirstSurvey = false
    /// The status of the survey submission.
    @State var submitSurveyOperation = Operation()
    /// Whether or not the Submit button should be disabled.
    var shouldDisableSubmitButton: Bool {
        question1Response == nil || question2Response == nil || submitSurveyOperation.status == .inProgress
    }
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            Group {
                if surveyCheckOperation.status == .inProgress {
                    ProgressView()
                        .controlSize(.large)
                    
                } else if surveyCheckOperation.status == .failure {
                    VStack(spacing: 13) {
                        Text("Couldn't Load Survey")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                        
                        Text(surveyCheckOperation.errorMessage)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            surveyCheckOperation.status = .inProgress
                            checkForSurveys()
                        }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                        }
                    }
                    
                } else {
                    VStack {
                        ScrollView {
                            HStack {
                                Text("\(isFirstSurvey ? "So far today:" : "Since the last survey:")")
                                    .dynamicFont(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding(.top, 5)
                            
                            VStack {
                                QuestionView(question: "Have you assisted your crew members to make sure they performed their work safely?",
                                             response: $question1Response,
                                             shouldDisableQuestionControls: submitSurveyOperation.status == .inProgress
                                )
                                .padding(.top, 5)
                                
                                QuestionView(question: "Have you taken action to protect your crew members from safety hazards or risky situations?",
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
                            .padding([.leading, .bottom, .trailing])
                            .padding(.top, 5)
                            .disabled(shouldDisableSubmitButton)
                    }
                }
            }
                .navigationTitle("Feedback Survey")
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
        .alert(isPresented: $submitSurveyOperation.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Submit Survey"),
                  message: Text(submitSurveyOperation.errorMessage),
                  dismissButton: .default(Text("Close"))
            )
        }
        .onAppear {
            checkForSurveys()
        }
    }
    
    // MARK: View Functions
    func checkForSurveys() {
        guard Auth.auth().currentUser != nil else {
            surveyCheckOperation.setError(message: "You are not signed in. Please sign in and try again.")
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        
        let surveysRef = Firestore.firestore()
            .collection("users")
            .document(Auth.auth().currentUser!.uid)
            .collection("ema_surveys")
        
        // Query for documents where the document name (a timestamp) falls within today's date
        let query = surveysRef.whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: Utilities.timestampToDateString(startOfDay.timeIntervalSince1970))
            .whereField(FieldPath.documentID(), isLessThan: Utilities.timestampToDateString(endOfDay!.timeIntervalSince1970))
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                surveyCheckOperation.setError(message: error.localizedDescription)
            } else {
                isFirstSurvey = !((querySnapshot?.documents.count ?? 0) > 0)
                surveyCheckOperation.status = .success
            }
        }
    }
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
                HStack {
                    Text(question)
                    
                    Spacer()
                }
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
