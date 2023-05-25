import SwiftUI

/// Contains information about the survey
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 25, 2023
///
struct SurveyInfoViewDetails: View {
    
    
    let infoFontSize: CGFloat = 15
    @Binding var toggleToRefresh: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    // Header
                    VStack {
                        Text("Details")
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
                        Text("The **rating-of-fatigue (ROF) scale** will allow you to rate how fatigued you feel. It is important that you first read the following guidelines:")
                            .padding(.bottom, 4)
                            .padding(.top, 12)
                            .frame(width: 360)
                            .font(.system(size: infoFontSize))
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("1. Please **familiarize yourself with the ROF scale** now.")
                                    .padding(.bottom, 16)
                                    .frame(width: 200)
                                    .font(.system(size: infoFontSize))
                                
                                Text("2. Please **carefully inspect** the ROF scale before giving a numerical response from 0 to 10. Always try to respond **as honestly as possible**, giving a rating that best reflects how fatigued you feel at the time.")
                                    .padding(.bottom, 16)
                                    .frame(width: 200)
                                    .font(.system(size: infoFontSize))
                            }
                            .frame(width: 200)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            VStack {
                                if DarkMode.isDarkMode() {
                                    Image("rof_scale")
                                        .resizable()
                                        .frame(width: 150, height: 150 * 1040 / 600)
                                        .cornerRadius(8)
                                        .colorInvert()
                                }
                                else {
                                    Image("rof_scale")
                                        .resizable()
                                        .frame(width: 150, height: 150 * 1040 / 600)
                                        .cornerRadius(8)
                                }
                                Text("ROF Scale")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            .frame(width: 150)
                        }
                        .frame(width: 360)
                        .padding(.bottom, 16)
                        
                        Text("3. **Try not to hesitate too much** and make sure you only give ONE number as a response.")
                            .frame(width: 360)
                            .padding(.bottom, 16)
                            .font(.system(size: infoFontSize))
                        
                        Text("4. Now, please read the following **examples** of what some of the ROF ratings mean:")
                            .padding(.bottom, 4)
                            .frame(width: 360)
                            .font(.system(size: infoFontSize))
                        
                        Text("· A response of 0 would indicate that you do not feel at all fatigued. An example of this might be soon after you wake up in the morning after having a good night’s sleep. Now try to think of a similar occasion in your past where you have experienced the lowest feelings of fatigue and use this as you reference.")
                            .padding(.bottom, 4)
                            .frame(width: 360)
                            .font(.system(size: infoFontSize))
                        
                        Text("· A response of 10 would indicate that you feel totally fatigued and exhausted. An example of this might be not being able to stay awake, perhaps late at night but equally could include situations such as sprinting until you can no longer physically continue. Again try to think of a similar example that you have actually experienced in the past.")
                            .padding(.bottom, 16)
                            .frame(width: 360)
                            .font(.system(size: infoFontSize))
                    }
                    .frame(width: 360)
                    .padding([.horizontal], 10)
                    .padding(.bottom, 20)
                    
                    // Next
                    let todaysResponses = SurveyInfoView.surveysSubmittedToday()
                    let (timePassed, nextTime) = SurveyInfoView.sufficientTimePassed()
                    if todaysResponses < 8 && timePassed {
                        NavigationLink(destination: SurveyView(toggleToRefresh: $toggleToRefresh)) {
                            IconButtonInner(iconName: "square.and.pencil", buttonText: "Continue to Survey")
                        }
                        .buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
                                             foregroundColor: .white))
                    }
                    
                    Spacer()
                        .frame(height: 32)
                }
                .frame(width: geometry.size.width)
            }
            
        }
        
        
    }
}
