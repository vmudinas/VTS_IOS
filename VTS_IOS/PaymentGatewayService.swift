import Foundation
import Combine
import SwiftUI
import UserNotifications

// Service to handle payment gateway functionality
class PaymentGatewayService: ObservableObject {
    @Published var isProcessingPayment: Bool = false
    @Published var isRefunding: Bool = false
    @Published var paymentSuccessful: Bool = false
    
    // Process payment using the selected payment method
    func processPayment(payment: Payment, completion: @escaping (Bool) -> Void) {
        // This would integrate with actual SDKs in a real implementation
        isProcessingPayment = true
        
        // Simulating payment processing with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isProcessingPayment = false
            self.paymentSuccessful = true
            
            // Add to notification center for payment reminders if recurring
            if payment.isRecurring {
                self.schedulePaymentReminder(for: payment)
            }
            
            completion(true)
        }
    }
    
    // Process refund for a payment
    func processRefund(payment: Payment, amount: Double, issuedBy: String, reason: String, completion: @escaping (Bool, Double, Date) -> Void) {
        guard payment.isPaid else {
            completion(false, 0, Date())
            return
        }
        
        isRefunding = true
        
        // Simulating refund processing with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isRefunding = false
            
            // In a real app, would validate refund amount against payment amount
            let refundAmount = min(amount, payment.amount)
            let refundDate = Date()
            
            // Schedule notification for the tenant
            self.scheduleRefundNotification(for: payment, amount: refundAmount, reason: reason)
            
            completion(true, refundAmount, refundDate)
        }
    }
    
    // Set up recurring payment
    func setupRecurringPayment(payment: Payment, frequency: PaymentFrequency) -> Payment {
        // In a real app, this would set up subscriptions with the payment provider
        var updatedPayment = payment
        updatedPayment.isRecurring = true
        updatedPayment.paymentFrequency = frequency
        
        // Calculate next due date based on frequency
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch frequency {
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
        case .annually:
            dateComponents.year = 1
        case .oneTime:
            updatedPayment.isRecurring = false
            return updatedPayment
        }
        
        if let nextDate = calendar.date(byAdding: dateComponents, to: payment.dueDate) {
            updatedPayment.nextDueDate = nextDate
        }
        
        return updatedPayment
    }
    
    // Schedule payment reminder notification
    private func schedulePaymentReminder(for payment: Payment) {
        guard let nextDueDate = payment.nextDueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "Your \(payment.description) payment of $\(String(format: "%.2f", payment.amount)) is due soon."
        content.sound = UNNotificationSound.default
        
        // Notification one day before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate) ?? nextDueDate
        let components = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "payment-\(payment.id)", content: content, trigger: trigger)
        
        // Add to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Schedule notification for refund
    private func scheduleRefundNotification(for payment: Payment, amount: Double, reason: String) {
        let content = UNMutableNotificationContent()
        content.title = "Refund Processed"
        content.body = "A refund of $\(String(format: "%.2f", amount)) has been issued for your \(payment.description) payment. Reason: \(reason)"
        content.sound = UNNotificationSound.default
        
        // Send notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "refund-\(payment.id)", content: content, trigger: trigger)
        
        // Add to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling refund notification: \(error)")
            }
        }
    }
}