import SwiftUI

/// Contains information about the survey
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 25, 2023
///
struct SurveyDetailsView: View {
    
    /// Font size for body text.
    let infoFontSize: CGFloat = 15
    
    /// Toggle this to refresh `SurveyInfoView`.
    @Binding var toggleToRefresh: Bool
    
    
    
    /// Each page shown inside SurveyDetailsView
    struct SurveyDetailsViewPage: View {
        
        var imagePath: String
        var imageWidth: CGFloat = 220
        var imageHeight: CGFloat = 220
        var titleText: String
        var bodyText: String

        
        var body: some View {
            VStack {
                Image(imagePath)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                
                Text(titleText)
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: 360)
                    .padding(.bottom, 16)
                
                Text(bodyText)
                    .frame(maxWidth: 320)
            }
            .frame(width: 360)
        }
    }
    
    @State var page: Int = 1
    let totalPages: Int = 5
    
    var body: some View {
        VStack {
            if page == 1 {
                SurveyDetailsViewPage(imagePath: "survey_details_1",
                                      titleText: "Welcome to the Fatigue Survey!",
                                      bodyText: "Your honest responses will help us predict your fatigue more accurately and personalize the model for you. All responses will be kept confidential. ")
            }
            else if page == 2 {
                SurveyDetailsViewPage(imagePath: "survey_details_2",
                                      titleText: "Minimum 5 surveys per day",
                                      bodyText: "During the day, you will be responding to a single-question survey at least 5 times. (maximum 8 times)\n\nA push notification will be sent every hour as a reminder until we receive 5 responses. ")
            }
            else if page == 3 {
                SurveyDetailsViewPage(imagePath: "survey_details_3",
                                      imageWidth: 220 / 644 * 588, imageHeight: 220,
                                      titleText: "Rate your fatigue level",
                                      bodyText: "You will be asked to rate your fatigue level based on the rating-of-fatigue (ROF) scale.\n\nPlease take a look at the levels and try to think of a similar occasion in your past as a reference.   ")
            }
            else if page == 4 {
                SurveyDetailsViewPage(imagePath: "survey_details_4",
                                      imageWidth: 220 / 510 * 502, imageHeight: 220,
                                      titleText: "ROF scale examples",
                                      bodyText: "A response of 0 would indicate that you do not feel fatigued at all, such as right after a good night’s sleep. \n\nA response of 10 would indicate that you feel totally exhausted, such as sprinting until you can no longer continue. ")
            }
            else if page == 5 {
                SurveyDetailsViewPage(imagePath: "survey_details_5",
                                      titleText: "Let's begin!",
                                      bodyText: "Thank you for your participation.\n\nLet's proceed to the survey!")
            }
            else {
                Text("Oops, an error has occured.")
            }
            
            
            Spacer()
            
            // Button
            HStack {
                Button(action: { page -= 1 }) {
                    Image(systemName: "arrow.left")
                }
                .frame(width: 60, height: 30)
                .background(Color(red: 0, green: 145/255, blue: 13/255))
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(page-1 < 1)
                .opacity(page-1 < 1 ? 0 : 1)
                
                Spacer()
                
                Text("\(page) / \(totalPages)")
                    .font(.system(size: 14))
                
                Spacer()
                
                if page+1 > totalPages { // to survey
                    let todaysResponses = SurveyManager.surveysSubmittedToday()
                    let (timePassed, nextTime) = SurveyManager.sufficientTimePassed()
                    
                    if todaysResponses < 8 && timePassed {
                        NavigationLink(destination: SurveyView(toggleToRefresh: $toggleToRefresh)) {
                            Image(systemName: "arrow.right")
                        }
                        .frame(width: 60, height: 30)
                        .background(Color(red: 0, green: 145/255, blue: 13/255))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    else if todaysResponses < 8 {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "clock")
                                    .imageScale(.small)
                                Text("\(nextTime)")
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(width: 100, height: 30)
                        .background(.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    else {
                        Button(action: {}) {
                            Text("N/A")
                                .font(.system(size: 14))
                        }
                        .frame(width: 60, height: 30)
                        .background(.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                else { // next page
                    Button(action: { page += 1 }) {
                        Image(systemName: "arrow.right")
                    }
                    .frame(width: 60, height: 30)
                    .background(Color(red: 0, green: 145/255, blue: 13/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
            }
            .padding([.horizontal], 8)
            .padding(.bottom, 18)
            
        } // VStack
        
        
        //        GeometryReader { geometry in
        //            ScrollView {
        //                VStack {
        //                    // Header
        //                    VStack {
        //                        Text("Details")
        //                            .font(.system(size: 32, weight: .bold))
        //                            .padding(.bottom, -4)
        //                        Text("Please read the following information carefully before responding.")
        //                            .frame(maxWidth: 360)
        //                            .multilineTextAlignment(.center)
        //                        Spacer()
        //                            .frame(height: 32)
        //                    }
        //
        //                    // Survey information
        //                    VStack(alignment: .leading) {
        //                        Text("The **rating-of-fatigue (ROF) scale** will allow you to rate how fatigued you feel. It is important that you first read the following guidelines:")
        //                            .padding(.bottom, 4)
        //                            .padding(.top, 12)
        //                            .frame(width: 360)
        //                            .font(.system(size: infoFontSize))
        //
        //                        HStack {
        //                            VStack(alignment: .leading) {
        //                                Text("1. Please **familiarize yourself with the ROF scale** now.")
        //                                    .padding(.bottom, 16)
        //                                    .frame(width: 200)
        //                                    .font(.system(size: infoFontSize))
        //
        //                                Text("2. Please **carefully inspect** the ROF scale before giving a numerical response from 0 to 10. Always try to respond **as honestly as possible**, giving a rating that best reflects how fatigued you feel at the time.")
        //                                    .padding(.bottom, 16)
        //                                    .frame(width: 200)
        //                                    .font(.system(size: infoFontSize))
        //                            }
        //                            .frame(width: 200)
        //
        //                            Spacer()
        //                                .frame(width: 10)
        //
        //                            VStack {
        //                                if DarkMode.isDarkMode() {
        //                                    Image("rof_scale")
        //                                        .resizable()
        //                                        .frame(width: 150, height: 150 * 1040 / 600)
        //                                        .cornerRadius(8)
        //                                        .colorInvert()
        //                                }
        //                                else {
        //                                    Image("rof_scale")
        //                                        .resizable()
        //                                        .frame(width: 150, height: 150 * 1040 / 600)
        //                                        .cornerRadius(8)
        //                                }
        //                                Text("ROF Scale")
        //                                    .font(.system(size: 14))
        //                                    .foregroundColor(Color(white: 0.5))
        //                            }
        //                            .frame(width: 150)
        //                        }
        //                        .frame(width: 360)
        //                        .padding(.bottom, 16)
        //
        //                        Text("3. **Try not to hesitate too much** and make sure you only give ONE number as a response.")
        //                            .frame(width: 360)
        //                            .padding(.bottom, 16)
        //                            .font(.system(size: infoFontSize))
        //
        //                        Text("4. Now, please read the following **examples** of what some of the ROF ratings mean:")
        //                            .padding(.bottom, 4)
        //                            .frame(width: 360)
        //                            .font(.system(size: infoFontSize))
        //
        //                        Text("· A response of 0 would indicate that you do not feel at all fatigued. An example of this might be soon after you wake up in the morning after having a good night’s sleep. Now try to think of a similar occasion in your past where you have experienced the lowest feelings of fatigue and use this as you reference.")
        //                            .padding(.bottom, 4)
        //                            .frame(width: 360)
        //                            .font(.system(size: infoFontSize))
        //
        //                        Text("· A response of 10 would indicate that you feel totally fatigued and exhausted. An example of this might be not being able to stay awake, perhaps late at night but equally could include situations such as sprinting until you can no longer physically continue. Again try to think of a similar example that you have actually experienced in the past.")
        //                            .padding(.bottom, 16)
        //                            .frame(width: 360)
        //                            .font(.system(size: infoFontSize))
        //                    }
        //                    .frame(width: 360)
        //                    .padding([.horizontal], 10)
        //                    .padding(.bottom, 20)
        //
        //                    // Next
//                            let todaysResponses = SurveyManager.surveysSubmittedToday()
//                            let (timePassed, nextTime) = SurveyManager.sufficientTimePassed()
//                            if todaysResponses < 8 && timePassed {
//                                NavigationLink(destination: SurveyView(toggleToRefresh: $toggleToRefresh)) {
//                                    IconButtonInner(iconName: "square.and.pencil", buttonText: "Continue to Survey")
//                                }
//                                .buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
//                                                     foregroundColor: .white))
//                            }
        //
        //                    Spacer()
        //                        .frame(height: 32)
        //                }
        //                .frame(width: geometry.size.width)
        //            }
        //
        //        }
        
        
    }
    
    
    
}
