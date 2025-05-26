import Foundation
import Combine
import SwiftUI

// Mock service for handling payment data
class PaymentService: ObservableObject {
    @Published var upcomingPayments: [Payment] = []
    @Published var paymentHistory: [Payment] = []
    let paymentGateway = PaymentGatewayService()
    
    init() {
        // Load sample data
        loadSamplePayments()
    }
    
    func loadSamplePayments() {
        let calendar = Calendar.current
        
        upcomingPayments = [
            Payment(
                amount: 120.00,
                dueDate: calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                description: "Monthly service fee",
                assignedTo: "user123",
                isPaid: false,
                isRecurring: true,
                paymentFrequency: .monthly,
                nextDueDate: calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            ),
            Payment(
                amount: 85.50,
                dueDate: calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                description: "Equipment rental",
                assignedTo: "user123",
                isPaid: false
            ),
            Payment(
                amount: 250.00,
                dueDate: calendar.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                description: "Annual maintenance",
                assignedTo: "user123",
                isPaid: false
            )
        ]
        
        // Add some paid payments to history
        paymentHistory = [
            Payment(
                amount: 95.00,
                dueDate: calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                description: "Previous service fee",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .stripe
            ),
            Payment(
                amount: 45.75,
                dueDate: calendar.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
                description: "Tool rental",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .paypal,
                hasRefund: true,
                refundAmount: 15.25
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func fetchUpcomingPayments() {
        // This would be an API call in a real application
        // For now, we just use the sample data
    }
    
    // Mark a payment as paid using the selected payment method
    func makePayment(payment: Payment, paymentMethod: PaymentMethod, completion: @escaping (Bool) -> Void) {
        var updatedPayment = payment
        updatedPayment.paymentMethod = paymentMethod
        
        paymentGateway.processPayment(payment: updatedPayment) { success in
            if success {
                if let index = self.upcomingPayments.firstIndex(where: { $0.id == payment.id }) {
                    var paidPayment = payment
                    paidPayment.isPaid = true
                    paidPayment.paymentMethod = paymentMethod
                    
                    self.upcomingPayments.remove(at: index)
                    self.paymentHistory.append(paidPayment)
                    self.paymentHistory.sort { $0.dueDate > $1.dueDate }
                    
                    // If recurring, add next payment to upcoming
                    if paidPayment.isRecurring, let nextDueDate = paidPayment.nextDueDate {
                        let nextPayment = Payment(
                            amount: paidPayment.amount,
                            dueDate: nextDueDate,
                            description: paidPayment.description,
                            assignedTo: paidPayment.assignedTo,
                            isPaid: false,
                            paymentMethod: paidPayment.paymentMethod,
                            isRecurring: true,
                            paymentFrequency: paidPayment.paymentFrequency,
                            nextDueDate: self.calculateNextDueDate(from: nextDueDate, frequency: paidPayment.paymentFrequency)
                        )
                        self.upcomingPayments.append(nextPayment)
                        self.upcomingPayments.sort { $0.dueDate < $1.dueDate }
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Process refund for a payment
    func refundPayment(payment: Payment, amount: Double, completion: @escaping (Bool) -> Void) {
        paymentGateway.processRefund(payment: payment, amount: amount) { success, refundAmount in
            if success {
                if let index = self.paymentHistory.firstIndex(where: { $0.id == payment.id }) {
                    var refundedPayment = payment
                    refundedPayment.hasRefund = true
                    refundedPayment.refundAmount = refundAmount
                    self.paymentHistory[index] = refundedPayment
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Set up recurring payment
    func setupRecurringPayment(payment: Payment, frequency: PaymentFrequency) {
        if let index = upcomingPayments.firstIndex(where: { $0.id == payment.id }) {
            let updatedPayment = paymentGateway.setupRecurringPayment(payment: payment, frequency: frequency)
            upcomingPayments[index] = updatedPayment
        }
    }
    
    // Calculate next due date based on frequency
    private func calculateNextDueDate(from date: Date, frequency: PaymentFrequency) -> Date? {
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
            return nil
        }
        
        return calendar.date(byAdding: dateComponents, to: date)
    }
}

// Mock service for handling issues
class IssueService: ObservableObject {
    @Published var issues: [Issue] = []
    
    init() {
        // Load sample data
        loadSampleIssues()
    }
    
    func loadSampleIssues() {
        issues = [
            Issue(
                title: "App crashes on startup",
                description: "The application sometimes crashes when starting on older devices",
                createdDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                status: .inProgress,
                createdBy: "user123"
            ),
            Issue(
                title: "Payment not processing",
                description: "Credit card payment fails with error code 402",
                createdDate: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                status: .open,
                createdBy: "user123"
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func createIssue(title: String, description: String) {
        let newIssue = Issue(
            title: title,
            description: description,
            createdBy: "user123"
        )
        issues.append(newIssue)
        
        // In a real app, this would be sent to a backend API
    }
}

// Mock service for handling video uploads
class VideoService: ObservableObject {
    @Published var videos: [Video] = []
    @Published var uploadProgress: Float = 0
    @Published var isUploading: Bool = false
    
    init() {
        // Load sample data
        loadSampleVideos()
    }
    
    func loadSampleVideos() {
        videos = [
            Video(
                title: "Site inspection - January",
                description: "Monthly site inspection video for January",
                uploadDate: Date().addingTimeInterval(-86400 * 10), // 10 days ago
                duration: 123,
                uploadStatus: .completed
            ),
            Video(
                title: "Equipment testing",
                description: "Testing new equipment installation",
                uploadDate: Date().addingTimeInterval(-86400 * 20), // 20 days ago
                duration: 305,
                uploadStatus: .completed
            )
        ]
    }
    
    // In a real app, this would upload video data to a server
    func uploadVideo(title: String, description: String, videoURL: URL, completion: @escaping (Bool) -> Void) {
        // Simulate network request
        isUploading = true
        uploadProgress = 0
        
        // Create a new video object
        let newVideo = Video(
            title: title,
            description: description,
            url: videoURL,
            uploadStatus: .uploading
        )
        
        videos.append(newVideo)
        
        // Simulate upload progress
        var progress: Float = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            progress += 0.1
            self.uploadProgress = min(progress, 1.0)
            
            if progress >= 1.0 {
                timer.invalidate()
                self.isUploading = false
                
                // Update the video status to completed
                if let index = self.videos.firstIndex(where: { $0.id == newVideo.id }) {
                    let updatedVideo = Video(
                        id: newVideo.id,
                        title: newVideo.title,
                        description: newVideo.description,
                        uploadDate: newVideo.uploadDate,
                        duration: newVideo.duration,
                        url: newVideo.url,
                        uploadStatus: .completed
                    )
                    self.videos[index] = updatedVideo
                }
                
                completion(true)
            }
        }
    }
}

// Mock service for handling history
class HistoryService: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    init() {
        // Load sample data
        loadSampleHistory()
    }
    
    func loadSampleHistory() {
        historyItems = [
            HistoryItem(
                activityType: .payment,
                description: "Paid $75.00 for Monthly subscription",
                date: Date().addingTimeInterval(-86400 * 3) // 3 days ago
            ),
            HistoryItem(
                activityType: .issue,
                description: "Created issue: 'Login problem on mobile'",
                date: Date().addingTimeInterval(-86400 * 7) // 7 days ago
            ),
            HistoryItem(
                activityType: .videoUpload,
                description: "Uploaded video: 'Project update - March'",
                date: Date().addingTimeInterval(-86400 * 14) // 14 days ago
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func addHistoryItem(item: HistoryItem) {
        historyItems.append(item)
        historyItems.sort { $0.date > $1.date } // Newest first
        
        // In a real app, this would be sent to a backend API
    }
}