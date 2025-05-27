import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions with our NotificationManager
        NotificationManager.shared.requestPermissions { granted in
            if granted {
                // Register for remote notifications (push notifications)
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Check for network connectivity and sync data if needed
        if !PersistenceManager.shared.isOffline {
            PersistenceManager.shared.syncWhenOnline { success in
                if success {
                    print("Initial sync completed successfully")
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token: \(tokenString)")
        
        // In a real app, you would send this token to your server
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if let typeString = userInfo["type"] as? String {
            switch typeString {
            case "payment_reminder":
                print("User tapped on payment reminder notification")
                // In a real app would navigate to payment screen
                
            case "issue_update":
                print("User tapped on issue update notification")
                // In a real app would navigate to issue details
                
            case "new_message":
                print("User tapped on new message notification")
                
                // If response contains a reply from quick action
                if response.actionIdentifier == "REPLY_MESSAGE", 
                   let textResponse = response as? UNTextInputNotificationResponse,
                   let sender = userInfo["sender"] as? String {
                    // Handle the reply
                    let replyText = textResponse.userText
                    print("Replying to \(sender): \(replyText)")
                    
                    // In a real app would send this message
                }
                
            case "document_update":
                print("User tapped on document notification")
                // In a real app would navigate to document
                
            case "sync_complete":
                print("User tapped on sync notification")
                // In a real app might navigate to recently updated content
                
            default:
                break
            }
        }
        
        completionHandler()
    }
}