import Foundation
import SwiftUI

class PaymentService: ObservableObject {
    @Published var upcomingPayments: [Payment] = []
    @Published var paymentHistory: [Payment] = []
    
    private let paymentGateway = PaymentGatewayService()
    private let historyService = HistoryService()
    
    init() {
        // Load sample data
        loadSamplePayments()
    }
    
    func loadSamplePayments() {
        // Generate some upcoming payments
        upcomingPayments = [
            Payment(
                amount: 1250.00,
                dueDate: Date().addingTimeInterval(86400 * 3), // 3 days from now
                description: "Rent Payment - June",
                assignedTo: "user123",
                isRecurring: true,
                paymentFrequency: .monthly,
                category: .rent
            ),
            Payment(
                amount: 150.00,
                dueDate: Date().addingTimeInterval(86400 * 5), // 5 days from now
                description: "Water and Sewage",
                assignedTo: "user123",
                isRecurring: true,
                paymentFrequency: .monthly,
                category: .utilities
            ),
            Payment(
                amount: 200.00,
                dueDate: Date().addingTimeInterval(86400 * 10), // 10 days from now
                description: "Maintenance Fee",
                assignedTo: "user123",
                isRecurring: false,
                category: .maintenance
            )
        ]
        
        // Generate some payment history
        paymentHistory = [
            Payment(
                amount: 1250.00,
                dueDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                description: "Rent Payment - May",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .bankTransfer,
                isRecurring: true,
                paymentFrequency: .monthly,
                category: .rent
            ),
            Payment(
                amount: 150.00,
                dueDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                description: "Water and Sewage",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .stripe,
                isRecurring: true,
                paymentFrequency: .monthly,
                category: .utilities
            ),
            Payment(
                amount: 1250.00,
                dueDate: Date().addingTimeInterval(-86400 * 60), // 60 days ago
                description: "Rent Payment - April",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .bankTransfer,
                isRecurring: true,
                paymentFrequency: .monthly,
                hasRefund: true,
                refundAmount: 250.00,
                refundIssuedBy: "landlord123",
                refundReason: "Maintenance issues with water heater",
                refundDate: Date().addingTimeInterval(-86400 * 55),
                category: .rent
            )
        ]
    }
    
    func fetchUpcomingPayments() {
        // In a real app, this would fetch from a backend API
    }
    
    func makePayment(payment: Payment, paymentMethod: PaymentMethod, completion: @escaping (Bool) -> Void) {
        paymentGateway.processPayment(payment: payment) { success in
            if success {
                if let index = self.upcomingPayments.firstIndex(where: { $0.id == payment.id }) {
                    var updatedPayment = payment
                    updatedPayment.isPaid = true
                    updatedPayment.paymentMethod = paymentMethod
                    
                    // Move to history
                    self.paymentHistory.insert(updatedPayment, at: 0)
                    
                    // Remove from upcoming if it's not recurring
                    if !payment.isRecurring {
                        self.upcomingPayments.remove(at: index)
                    } else {
                        // Schedule next payment
                        let updatedRecurringPayment = self.paymentGateway.setupRecurringPayment(payment: updatedPayment, frequency: updatedPayment.paymentFrequency)
                        self.upcomingPayments[index] = updatedRecurringPayment
                    }
                }
                
                // Add to history
                self.historyService.addHistoryItem(item: HistoryItem(
                    activityType: .payment,
                    description: "Payment of $\(String(format: "%.2f", payment.amount)) made for \(payment.description)",
                    relatedItemId: payment.id
                ))
            }
            
            completion(success)
        }
    }
    
    func refundPayment(payment: Payment, amount: Double, issuedBy: String, reason: String, completion: @escaping (Bool) -> Void) {
        guard payment.isPaid, !payment.hasRefund else {
            completion(false)
            return
        }
        
        paymentGateway.processRefund(payment: payment, amount: amount, issuedBy: issuedBy, reason: reason) { success, refundAmount, refundDate in
            if success {
                if let index = self.paymentHistory.firstIndex(where: { $0.id == payment.id }) {
                    var updatedPayment = payment
                    updatedPayment.hasRefund = true
                    updatedPayment.refundAmount = refundAmount
                    updatedPayment.refundIssuedBy = issuedBy
                    updatedPayment.refundReason = reason
                    updatedPayment.refundDate = refundDate
                    
                    self.paymentHistory[index] = updatedPayment
                    
                    // Add to history
                    self.historyService.addHistoryItem(item: HistoryItem(
                        activityType: .payment,
                        description: "Refund of $\(String(format: "%.2f", refundAmount)) issued for \(payment.description)",
                        relatedItemId: payment.id
                    ))
                }
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func setupRecurringPayment(payment: Payment, frequency: PaymentFrequency) {
        guard let index = upcomingPayments.firstIndex(where: { $0.id == payment.id }) else { return }
        
        let updatedPayment = paymentGateway.setupRecurringPayment(payment: payment, frequency: frequency)
        upcomingPayments[index] = updatedPayment
        
        // Add to history
        self.historyService.addHistoryItem(item: HistoryItem(
            activityType: .payment,
            description: "Set up recurring \(frequency.rawValue.lowercased()) payment for \(payment.description)",
            relatedItemId: payment.id
        ))
    }
    
    // Financial reporting methods
    func calculateIncome(from startDate: Date, to endDate: Date) -> Double {
        let relevantPayments = paymentHistory.filter { payment in
            let date = payment.dueDate
            return date >= startDate && date <= endDate && payment.isPaid && (payment.category?.isIncome ?? false)
        }
        
        return relevantPayments.reduce(0) { sum, payment in
            sum + payment.amount - (payment.refundAmount ?? 0)
        }
    }
    
    func calculateExpenses(from startDate: Date, to endDate: Date) -> Double {
        let relevantPayments = paymentHistory.filter { payment in
            let date = payment.dueDate
            return date >= startDate && date <= endDate && payment.isPaid && !(payment.category?.isIncome ?? true)
        }
        
        return relevantPayments.reduce(0) { sum, payment in
            sum + payment.amount
        }
    }
    
    func calculateProfitLoss(from startDate: Date, to endDate: Date) -> Double {
        let income = calculateIncome(from: startDate, to: endDate)
        let expenses = calculateExpenses(from: startDate, to: endDate)
        return income - expenses
    }
    
    func incomeByCategory(from startDate: Date, to endDate: Date) -> [PaymentCategory: Double] {
        var result: [PaymentCategory: Double] = [:]
        
        let relevantPayments = paymentHistory.filter { payment in
            let date = payment.dueDate
            return date >= startDate && date <= endDate && payment.isPaid && (payment.category?.isIncome ?? false)
        }
        
        for payment in relevantPayments {
            if let category = payment.category {
                let amount = payment.amount - (payment.refundAmount ?? 0)
                result[category] = (result[category] ?? 0) + amount
            }
        }
        
        return result
    }
    
    func expensesByCategory(from startDate: Date, to endDate: Date) -> [PaymentCategory: Double] {
        var result: [PaymentCategory: Double] = [:]
        
        let relevantPayments = paymentHistory.filter { payment in
            let date = payment.dueDate
            return date >= startDate && date <= endDate && payment.isPaid && !(payment.category?.isIncome ?? true)
        }
        
        for payment in relevantPayments {
            if let category = payment.category {
                result[category] = (result[category] ?? 0) + payment.amount
            }
        }
        
        return result
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) -> [Payment] {
        return paymentHistory.filter { payment in
            let date = payment.dueDate
            return date >= startDate && date <= endDate && payment.isPaid
        }.sorted { $0.dueDate > $1.dueDate }
    }
    
    func exportToCSV(from startDate: Date, to endDate: Date) -> String {
        let transactions = getTransactions(from: startDate, to: endDate)
        
        var csv = "Date,Description,Amount,Category,Payment Method,Status\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.dueDate)
            let description = transaction.description.replacingOccurrences(of: ",", with: " ")
            let amount = String(format: "%.2f", transaction.amount)
            let category = transaction.category?.rawValue ?? "Uncategorized"
            let method = transaction.paymentMethod?.rawValue ?? "Unknown"
            let status = transaction.hasRefund ? "Refunded: \(transaction.refundAmount ?? 0)" : "Completed"
            
            csv += "\(date),\(description),\(amount),\(category),\(method),\(status)\n"
        }
        
        return csv
    }
}