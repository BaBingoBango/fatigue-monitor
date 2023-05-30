//
//  E4 tester
//
//

import SwiftUI
import FirebaseCore

 @main
struct DPMApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var modelData = ModelData()
    
    @AppStorage("userOnboarded") var userOnboarded: Bool = false
    @State var showOnboarding: Bool = true
    

    
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
            
            if userOnboarded {
                ContentView()
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
            }
            else {
                OnboardingView(userOnboarded: $userOnboarded)
                    .environmentObject(modelData)
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

/// Connects to Firebase on app launch
///
/// ### Usage
/// ```
/// struct YourApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
///     // stuff...
/// }
/// ```
///
/// ### Author & Version
/// Provided by Firebase, as of May 16, 2023.
///
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
