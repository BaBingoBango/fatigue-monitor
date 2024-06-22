//
//  E4 tester
//
//

import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth

@main
struct DPMApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var modelData = ModelData()
    
    @AppStorage("userOnboarded") var userOnboarded: Bool = false
    @State var showOnboarding: Bool = true
    
    @State var isSignedIn: Bool? = nil
    @State var isShowingEMASurvey = false
    
    // Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        print("EmpaticaAPI initialized")
        EmpaticaAPI.initialize()
        askNotificationPermission()
        cancelRegularNotification()
        registerRegularNotification()
    }
    
    func resetFatigueLevel(){
        let today = Calendar.current.component(.day, from: Date())
        if (modelData.lastResetDay == 0 || today != modelData.lastResetDay) {
            modelData.fatigueLevel = 0
            modelData.lastResetDay = today
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let isSignedIn = isSignedIn {
                    if isSignedIn {
                        ContentView(userChecker: .init(uid: Auth.auth().currentUser!.uid))
                            .environmentObject(modelData)
                            .onAppear {
                                ModelData.load { result in
                                    switch result {
                                    case .failure(let error):
                                        fatalError(error.localizedDescription)
                                    case .success(let user):
                                        modelData.user = user
                                    }
                                }
                            }
                    } else {
                        OnboardingView(userOnboarded: $userOnboarded)
                            .environmentObject(modelData)
                    }
                    
                    // If not, check the Auth object!
                } else {
                    if Auth.auth().currentUser != nil {
                        ContentView(userChecker: .init(uid: Auth.auth().currentUser!.uid))
                            .environmentObject(modelData)
                            .onAppear {
                                ModelData.load { result in
                                    switch result {
                                    case .failure(let error):
                                        fatalError(error.localizedDescription)
                                    case .success(let user):
                                        modelData.user = user
                                    }
                                }
                            }
                    } else {
                        OnboardingView(userOnboarded: $userOnboarded)
                            .environmentObject(modelData)
                    }
                }
            }
            .onAppear {
                // MARK: App Launch Code
                // Listen to the auth status!
                _ = Auth.auth().addStateDidChangeListener { auth, user in
                    
                    if user != nil {
                        isSignedIn = true
                    } else {
                        isSignedIn = false
                    }
                }
                NotificationCenter.default.addObserver(
                    forName: .init("ShowEMASurveyNotification"),
                    object: nil,
                    queue: .main
                ) { [self] _ in
                    self.isShowingEMASurvey = true
                }
            }
            .sheet(isPresented: $isShowingEMASurvey) {
                EMASurveyView()
            }
            .onChange(of: delegate.launchedFromNotification) { newValue in
                print("DIDR - changed to \(newValue)")
                if newValue {
                    isShowingEMASurvey = true
                    delegate.launchedFromNotification = false
                }
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("App is active")
                EmpaticaAPI.prepareForResume()
                resetFatigueLevel()
                
                // Register notification categories and actions!
                let action = UNNotificationAction(identifier: "SURVEY_ACTION",
                                                      title: "Take Survey",
                                                      options: UNNotificationActionOptions.foreground)

                let category = UNNotificationCategory(identifier: "EMA_SURVEY",
                                                      actions: [action],
                                                      intentIdentifiers: [],
                                                      options: [])

                UNUserNotificationCenter.current().setNotificationCategories([category])
                
            case .inactive:
                print("App is inactive")
                ModelData.save(user: modelData.user) { result in
                     if case .failure(let error) = result {
                         fatalError(error.localizedDescription)
                     }
                 }
            case .background:
                print("App is in background")
                EmpaticaAPI.prepareForBackground()
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
}

func getPreviewPeers() -> [Peer] {
    var previewPeers: [Peer] = []
    
    let alex = Peer(id: "A", firstName: "Alex")
    alex.observations = [
        .init(hour_from_midnight: 8, fatigue_level_range: 30..<50, avg_fatigue_level: 40),
        .init(hour_from_midnight: 9, fatigue_level_range: 50..<50, avg_fatigue_level: 50),
        .init(hour_from_midnight: 10, fatigue_level_range: 10..<50, avg_fatigue_level: 30),
        .init(hour_from_midnight: 11, fatigue_level_range: 0..<40, avg_fatigue_level: 20)
    ]
    alex.heatObservations = [
        .init(hourFromMidnight: 8, heatStrainRange: 0..<2, averageHeatStrain: 1),
        .init(hourFromMidnight: 9, heatStrainRange: 3..<5, averageHeatStrain: 4),
        .init(hourFromMidnight: 10, heatStrainRange: 6..<6, averageHeatStrain: 6),
        .init(hourFromMidnight: 11, heatStrainRange: 4..<10, averageHeatStrain: 7)
    ]
    previewPeers.append(alex)
    
    let brynn = Peer(id: "B", firstName: "Brynn")
    brynn.observations = [
        .init(hour_from_midnight: 8, fatigue_level_range: 30..<90, avg_fatigue_level: 84),
        .init(hour_from_midnight: 9, fatigue_level_range: 80..<100, avg_fatigue_level: 92),
        .init(hour_from_midnight: 10, fatigue_level_range: 24..<40, avg_fatigue_level: 29),
        .init(hour_from_midnight: 11, fatigue_level_range: 15..<40, avg_fatigue_level: 35)
    ]
    brynn.heatObservations = [
        .init(hourFromMidnight: 8, heatStrainRange: 5..<8, averageHeatStrain: 8),
        .init(hourFromMidnight: 9, heatStrainRange: 1..<7, averageHeatStrain: 5),
        .init(hourFromMidnight: 10, heatStrainRange: 6..<10, averageHeatStrain: 8),
        .init(hourFromMidnight: 11, heatStrainRange: 4..<10, averageHeatStrain: 9)
    ]
    previewPeers.append(brynn)
    
    return previewPeers
}
