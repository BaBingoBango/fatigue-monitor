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
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("App is active")
                EmpaticaAPI.prepareForResume()
                resetFatigueLevel()
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
