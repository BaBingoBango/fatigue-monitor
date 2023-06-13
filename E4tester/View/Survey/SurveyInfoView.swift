import SwiftUI

/// Contains information about the survey
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 25, 2023
///
struct SurveyInfoView: View {
    
    /// User must read the details to enable the continue button at least once.
    @AppStorage("userReadSurveyDetails") var continueButtonEnabled: Bool = false
    
    /// Change this value to refresh the screen.
    @State var toggleToRefresh: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        // Text
                        VStack {
                            // Header
                            VStack {
                                Spacer()
                                    .frame(height: 64)
                                Text("Fatigue Survey")
                                    .font(.system(size: 32, weight: .bold))
                                    .padding(.bottom, -4)
                                Text("Please read the following information carefully before responding.")
                                    .frame(maxWidth: 360)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                    .frame(height: 32)
                            }
                            
                            // Survey information
                            VStack(alignment: .leading) {
                                Text("Your responses will be used to personalize our fatigue prediction model for you. Your honest responses will help us predict your fatigue more accurately. All responses will be kept confidential.")
                                    .padding(.bottom, 12)
                                Text("During the day, you'll need to respond to a single-question survey at least 5 times per day (maximum 8 times). We'll notify you every hour until we receive 5 responses.")
                            }
                            .frame(width: 350)
                            .padding([.horizontal], 10)
                        } // VStack
                        .frame(alignment: .top)
                        .padding(.bottom, 24)
                        
                        Spacer()
                        
                        // Responses today (8 bars)
                        let todaysResponses = SurveyManager.surveysSubmittedToday()
                        VStack {
                            if toggleToRefresh {}
                            Text("Responses today: \(todaysResponses)")
                            HStack {
                                ForEach(0..<8) { index in
                                    if index < todaysResponses { // green
                                        Text("○")
                                            .font(.system(size: 6))
                                            .frame(width: 30, height: 8)
                                            .padding([.horizontal], 0.5)
                                            .background(Color.green)
                                            .foregroundColor(.black)
                                    }
                                    else {
                                        if index >= 5 { // optional - gray
                                            Text("")
                                                .font(.system(size: 8))
                                                .frame(width: 30, height: 8)
                                                .padding([.horizontal], 0.5)
                                                .background(DarkMode.isDarkMode() ? Color(white: 0.4) : Color(white: 0.6))
                                                .foregroundColor(.black)
                                        }
                                        else { // required - red
                                            Text("-")
                                                .font(.system(size: 8))
                                                .frame(width: 30, height: 8)
                                                .padding([.horizontal], 0.5)
                                                .background(Color(red: 225/255, green: 106/255, blue: 131/255))
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            } // HStack
                        } // VStack
                        .padding(.bottom, 32)
                        
                        // Buttons
                        VStack {
                            // More details
                            NavigationLink(destination: SurveyInfoViewDetails(toggleToRefresh: $toggleToRefresh)) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("Details")
                                    Image(systemName: "arrow.right")
                                }
                                .padding(.bottom, 8)
                                
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                continueButtonEnabled = true
                                toggleToRefresh.toggle()
                            })

                            // Continue button
                            if todaysResponses < 8 { // responses left
                                let (timePassed, nextTime) = SurveyManager.sufficientTimePassed()
                                
                                if !timePassed { // not yet
                                    Text("Please return at \(nextTime) for the next survey.")
                                }
                                else if continueButtonEnabled {
                                    // continue
                                    NavigationLink(destination: SurveyView(toggleToRefresh: $toggleToRefresh)) {
                                        IconButtonInner(iconName: "square.and.pencil", buttonText: "Continue to Survey")
                                    }
                                    .buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
                                                         foregroundColor: .white))
                                    .opacity(continueButtonEnabled ? 1.0 : 0.5)
                                }
                                else { // first time
                                    Text("Please read the details to continue.")
                                }
                            }
                            else { // max reached
                                Text("You can only submit 8 surveys per day.")
                            }
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        .frame(alignment: .bottom)
                        
                    } // Vstack
                    .frame(width: geometry.size.width)
                } // ScrollView
            } // GeometryReader
        } // NavigationView
    }
}
