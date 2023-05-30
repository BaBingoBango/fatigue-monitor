import SwiftUI

/// Survey view
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 25, 2023
///
struct SurveyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var timer = Timer.publish(every: 3, on: .main, in: .common)
                            .autoconnect()
    @State var submitButtonEnabled = false
    @State var dropdownValue: Int = 0
    @Binding var toggleToRefresh: Bool
    
    @State var showPopup: Bool = false
    @State var popupText: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            // Header
            VStack{
                Spacer()
                    .frame(height: 32)
                Text("Fatigue Survey")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, -4)
                Text("What is your current fatigue level?")
                    .frame(maxWidth: 360)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 24)
            }
            
            // ROF scale
            GeometryReader { geometry in
                VStack(alignment: .center)  {
                    let height = geometry.size.height * 0.9
                    if DarkMode.isDarkMode() {
                        Image("rof_scale")
                            .resizable()
                            .frame(width: height * 600 / 1040, height: height)
                            .cornerRadius(12)
                            .colorInvert()
                    }
                    else {
                        Image("rof_scale")
                            .resizable()
                            .frame(width: height * 600 / 1040, height: height)
                            .cornerRadius(23)
                    }
                }
                .frame(width: geometry.size.width)
            }
            
            // submit
            VStack {
                SimpleDropdown(label: "Fatigue level:",
                               optionTexts: ["10 (total fatigue)", "9", "8", "7", "6",
                                             "5 (moderate fatigue)", "4", "3", "2",
                                             "1", "0 (no fatigue)"],
                               optionValues: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
                               value: $dropdownValue)
                
                Spacer()
                    .frame(height: 32)
                
                Button(action: {
                    // button actions
                    if !submitButtonEnabled {
                        return
                    }
                    // submit
                    FirebaseManager.submitSurvey(fatigueLevel: dropdownValue)
                    SurveyInfoView.addSurveyTimestamp(Date().timeIntervalSince1970)
                    
                    // schedule notification?
                    let surveysSubmittedToday = SurveyInfoView.surveysSubmittedToday()
                    let (_, nextTime) = SurveyInfoView.sufficientTimePassed()
                    if surveysSubmittedToday < 5 {
                        scheduleSurveyNotification(secondsAfter: 60)
                    }
                    
                    // Popup
                    if surveysSubmittedToday < 5 {
                        popupText = "Thank you! Please return at \(nextTime) for the next survey; we'll send you a notification at that time."
                    }
                    else if surveysSubmittedToday < 8 {
                        popupText = "Thank you! You can submit \(8 - surveysSubmittedToday) more surveys today but they are not required. You can submit another after \(nextTime)."
                    }
                    else {
                        popupText = "Thank you! You have submitted all 8 survey responses today."
                    }
                    showPopup = true
                }) {
                    if submitButtonEnabled {
                        IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
                    }
                    else {
                        IconButtonInner(iconName: "timer", buttonText: "Submit")
                    }
                }
                .buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
                                     foregroundColor: .white))
                .opacity(submitButtonEnabled ? 1.0 : 0.6)
                .onReceive(timer) { _ in
                    submitButtonEnabled = true
                }
                
                Spacer()
                    .frame(height: 32)
            }
            // Popup
            .alert("Submitted", isPresented: $showPopup, actions: {
                Button("Close", role: nil, action: {
                    // close and refresh
                    toggleToRefresh.toggle()
                    showPopup = false
                    self.presentationMode.wrappedValue.dismiss()
                })
            }, message: {
                Text(popupText)
            })
            
        }
        .onAppear {
            timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        }
        
    }
}
