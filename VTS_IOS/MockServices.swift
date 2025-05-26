import Foundation
import Combine
import SwiftUI

// Mock service for handling payment data
class PaymentService: ObservableObject {
    @Published var upcomingPayments: [Payment] = []
    
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
                isPaid: false
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
    }
    
    // In a real app, this would make an API call to the backend
    func fetchUpcomingPayments() {
        // This would be an API call in a real application
        // For now, we just use the sample data
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