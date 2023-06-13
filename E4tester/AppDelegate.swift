import Foundation
import FirebaseCore
import FirebaseMessaging

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
/// Modified by Seung-Gu Lee on Jun 6, 2023
///
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Called on app launch
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // initialize
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        // register for remote notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        return true
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Called on notification received
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    /// Called on notification received
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: tokenDict)
      }
}
