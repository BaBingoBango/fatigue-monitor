import SwiftUI

/// Contains information about the survey
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 25, 2023
///
struct SurveyInfoView: View {
    
    @AppStorage("userReadSurveyDetails") var continueButtonEnabled: Bool = false
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
                        }
                        .frame(alignment: .top)
                        .padding(.bottom, 24)
                        
                        Spacer()
                        
                        // Responses today (8 bars)
                        let todaysResponses = surveysSubmittedToday()
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
                            }
                            
                        }
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
                            if todaysResponses < 8 {
                                let (timePassed, nextTime) = SurveyInfoView.sufficientTimePassed()
                                
                                if !timePassed {
                                    // time passed
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
                                else {
                                    // first time
                                    Text("Please read the details to continue.")
                                }
                            }
                            else {
                                // max
                                Text("You can only submit 8 surveys per day.")
                            }
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        .frame(alignment: .bottom)
                        
                    }
                    .frame(width: geometry.size.width)
                }
                
            }
        }
    }
    
    /// Returns the number of surveys submitted by the user today.
    func surveysSubmittedToday() -> Int {
        return SurveyInfoView.surveysSubmittedToday()
    }
    
    /// Returns the number of surveys submitted by the user today.
    static func surveysSubmittedToday() -> Int {
        var count: Int = 0
        let todayMidnight = Date().startOfDay.timeIntervalSince1970
        let endTime = todayMidnight + 86400; // + 1 day
        
        let curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        for timestamp in curArr {
            if timestamp > todayMidnight && timestamp < endTime { // today
                count += 1
            }
        }
        
        return count
    }
    
    /// Returns a pair of string and bool:
    /// - Bool: true if sufficient time (default 60 min) has passed since last survey submission, false otherwise
    /// - String: next earliest time user can submit a form if false. Trivial value returned when returning true
    static func sufficientTimePassed() -> (Bool, String) {
        let minTime: Double = 3600 // seconds
        let curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        if curArr.isEmpty { // first response
            return (true, "")
        }
        
        let now = Date().timeIntervalSince1970
        let nextEarliest = curArr.last! + minTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let ok: Bool = nextEarliest - 60 < now // minus 1 minute for some flexibility
        let time = dateFormatter.string(from: Date(timeIntervalSince1970: nextEarliest))
        return (ok, time)
    }
    
    /// Adds survey timestamp to AppStorage
    static func addSurveyTimestamp(_ timestamp: Double) {
        var curArr = UserDefaults.standard.object(forKey: "submittedSurveyTimestamps") as? [Double] ?? []
        curArr.append(timestamp)
        UserDefaults.standard.set(curArr, forKey: "submittedSurveyTimestamps")
    }
}
