import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    // Notification categories
    enum NotificationType: String {
        case payment = "payment"
        case issue = "issue"
        case message = "message"
        case document = "document"
        case sync = "sync"
    }
    
    private var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    // User notification preferences
    var paymentNotificationsEnabled = true
    var issueNotificationsEnabled = true
    var messageNotificationsEnabled = true
    var documentNotificationsEnabled = true
    var syncNotificationsEnabled = true
    
    // Initialize and set up notification categories
    private init() {
        // Load user preferences
        loadNotificationPreferences()
        
        // Register notification categories with actions
        setupNotificationCategories()
    }
    
    // Request notification permissions
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Notification permission error: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    // Register notification categories with actions
    private func setupNotificationCategories() {
        // Payment notification actions
        let viewPaymentAction = UNNotificationAction(
            identifier: "VIEW_PAYMENT",
            title: "View Payment",
            options: .foreground
        )
        
        let paymentCategory = UNNotificationCategory(
            identifier: NotificationType.payment.rawValue,
            actions: [viewPaymentAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Issue notification actions
        let viewIssueAction = UNNotificationAction(
            identifier: "VIEW_ISSUE",
            title: "View Issue",
            options: .foreground
        )
        
        let issueCategory = UNNotificationCategory(
            identifier: NotificationType.issue.rawValue,
            actions: [viewIssueAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Message notification actions
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_MESSAGE",
            title: "Reply",
            options: .foreground,
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply"
        )
        
        let messageCategory = UNNotificationCategory(
            identifier: NotificationType.message.rawValue,
            actions: [replyAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Document notification actions
        let viewDocumentAction = UNNotificationAction(
            identifier: "VIEW_DOCUMENT",
            title: "View Document",
            options: .foreground
        )
        
        let documentCategory = UNNotificationCategory(
            identifier: NotificationType.document.rawValue,
            actions: [viewDocumentAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Register all categories
        notificationCenter.setNotificationCategories([
            paymentCategory,
            issueCategory,
            messageCategory,
            documentCategory
        ])
    }
    
    // Load user notification preferences
    private func loadNotificationPreferences() {
        let defaults = UserDefaults.standard
        paymentNotificationsEnabled = defaults.bool(forKey: "paymentNotificationsEnabled")
        issueNotificationsEnabled = defaults.bool(forKey: "issueNotificationsEnabled")
        messageNotificationsEnabled = defaults.bool(forKey: "messageNotificationsEnabled")
        documentNotificationsEnabled = defaults.bool(forKey: "documentNotificationsEnabled")
        syncNotificationsEnabled = defaults.bool(forKey: "syncNotificationsEnabled")
    }
    
    // Save user notification preferences
    func saveNotificationPreferences() {
        let defaults = UserDefaults.standard
        defaults.set(paymentNotificationsEnabled, forKey: "paymentNotificationsEnabled")
        defaults.set(issueNotificationsEnabled, forKey: "issueNotificationsEnabled")
        defaults.set(messageNotificationsEnabled, forKey: "messageNotificationsEnabled")
        defaults.set(documentNotificationsEnabled, forKey: "documentNotificationsEnabled")
        defaults.set(syncNotificationsEnabled, forKey: "syncNotificationsEnabled")
    }
    
    // Schedule payment reminder notification
    func schedulePaymentReminder(for payment: Payment) {
        guard paymentNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "Your \(payment.description) payment of \(LocalizationManager.shared.formatCurrency(payment.amount)) is due soon."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationType.payment.rawValue
        content.userInfo = [
            "paymentId": payment.id.uuidString,
            "type": "payment_reminder"
        ]
        
        // Schedule notification for one day before due date
        if let nextDueDate = payment.nextDueDate ?? (payment.isRecurring ? payment.dueDate : nil) {
            let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate) ?? nextDueDate
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create the request
            let request = UNNotificationRequest(
                identifier: "payment-\(payment.id.uuidString)",
                content: content,
                trigger: trigger
            )
            
            // Add to notification center
            scheduleNotification(request: request)
        }
    }
    
    // Schedule issue status update notification
    func scheduleIssueUpdate(for issue: Issue, status: IssueStatus) {
        guard issueNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Issue Update"
        content.body = "Your issue '\(issue.title)' has been updated to \(status.rawValue)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationType.issue.rawValue
        content.userInfo = [
            "issueId": issue.id.uuidString,
            "type": "issue_update"
        ]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "issue-\(issue.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add to notification center
        scheduleNotification(request: request)
    }
    
    // Schedule new message notification
    func scheduleNewMessageNotification(from sender: String, content messageContent: String) {
        guard messageNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.body = "\(sender): \(messageContent)"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationType.message.rawValue
        content.userInfo = [
            "sender": sender,
            "type": "new_message"
        ]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request with unique ID based on timestamp
        let requestId = "message-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: requestId,
            content: content,
            trigger: trigger
        )
        
        // Add to notification center
        scheduleNotification(request: request)
    }
    
    // Schedule document status notification
    func scheduleDocumentNotification(for document: Document) {
        guard documentNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Document Update"
        content.body = "Document '\(document.title)' requires your attention"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationType.document.rawValue
        content.userInfo = [
            "documentId": document.id.uuidString,
            "type": "document_update"
        ]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "document-\(document.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add to notification center
        scheduleNotification(request: request)
    }
    
    // Schedule data sync notification
    func scheduleSyncCompleteNotification(itemsUpdated: Int) {
        guard syncNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Sync Complete"
        content.body = "Your data is now up to date. \(itemsUpdated) items were synced."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationType.sync.rawValue
        content.userInfo = [
            "type": "sync_complete"
        ]
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request with unique ID based on timestamp
        let requestId = "sync-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: requestId,
            content: content,
            trigger: trigger
        )
        
        // Add to notification center
        scheduleNotification(request: request)
    }
    
    // Generic method to schedule a notification
    private func scheduleNotification(request: UNNotificationRequest) {
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Cancel all notifications of a specific type
    func cancelNotifications(for type: NotificationType) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { request in
                request.content.categoryIdentifier == type.rawValue
            }.map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}