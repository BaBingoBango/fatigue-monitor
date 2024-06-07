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
                                    .padding(.bottom, 12)
                                Text("Your responses will be used to personalize our fatigue prediction model for you.")
                                    .frame(maxWidth: 320)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                    .frame(height: 28)
                            }
                        } // VStack
                        .frame(alignment: .top)
                        .padding(.bottom, 4)
                        
                        // Responses today
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "checkmark.square")
                                Text("Responses Today")
                                Spacer()
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding([.horizontal], 20)
                        }
                        .padding(.bottom, 8)
                        
                        // Responses today (8 bars)
                        let todaysResponses = SurveyManager.surveysSubmittedToday()
                        VStack {
                            if toggleToRefresh {}
                            let checkmarkSize: CGFloat = 30
                            let checkmarkHorizPadding: CGFloat = 8
                            let checkmarkVertPadding: CGFloat = 4
                            HStack {
                                ForEach(0..<5) { index in
                                    if index < todaysResponses { // green
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .frame(width: checkmarkSize, height: checkmarkSize)
                                            .padding([.horizontal], checkmarkHorizPadding)
                                            .padding([.vertical], checkmarkVertPadding)
                                            .foregroundColor(Color(red: 53/255, green: 199/255, blue: 89/255))
                                    }
                                    else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .frame(width: checkmarkSize, height: checkmarkSize)
                                            .padding([.horizontal], checkmarkHorizPadding)
                                            .padding([.vertical], checkmarkVertPadding)
                                            .foregroundColor(DarkMode.isDarkMode() ? Color(white: 0.2) : Color(white: 0.8))
                                    }
                                }
                            } // HStack
                            HStack {
                                ForEach(5..<8) { index in
                                    if index < todaysResponses { // green
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .frame(width: checkmarkSize, height: checkmarkSize)
                                            .padding([.horizontal], checkmarkHorizPadding)
                                            .padding([.vertical], checkmarkVertPadding)
                                            .foregroundColor(Color(red: 53/255, green: 199/255, blue: 89/255))
                                    }
                                    else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .frame(width: checkmarkSize, height: checkmarkSize)
                                            .padding([.horizontal], checkmarkHorizPadding)
                                            .padding([.vertical], checkmarkVertPadding)
                                            .foregroundColor(DarkMode.isDarkMode() ? Color(white: 0.2) : Color(white: 0.8))
                                    }
                                }
                            } // HStack
                        } // VStack
                        .frame(width: 360)
                        .padding(.bottom, 24)
                        
                        // Next survey
                        VStack() {
                            HStack {
                                Image(systemName: "clock")
                                Text("Next Survey")
                                Spacer()
                            }
                            .font(.system(size: 20, weight: .semibold))
                            .padding([.horizontal], 20)
                            
                            let (timePassed, nextTime) = SurveyManager.sufficientTimePassed()
                            Text(timePassed ? "Now" : nextTime)
                                .font(.system(size: 20, weight: .bold))
                                .padding(.top, 4)
                        }
                        .padding(.bottom, 32)
                        
                        // Buttons
                        VStack {
                            // More details
                            NavigationLink(destination: SurveyDetailsView(toggleToRefresh: $toggleToRefresh)) {
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
                                    // continue
                                    NavigationLink(destination: SurveyView(toggleToRefresh: $toggleToRefresh)) {
                                        IconButtonInner(iconName: "square.and.pencil", buttonText: "Continue to Survey")
                                    }
                                    .buttonStyle(IconButtonStyle(backgroundColor: .gray,
                                                         foregroundColor: .white))
                                    .opacity(0.5)
                                    .disabled(true)
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

struct SurveyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyInfoView(continueButtonEnabled: true, toggleToRefresh: false)
            .environmentObject(ModelData())
    }
}
