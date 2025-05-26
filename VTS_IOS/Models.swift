import Foundation

// Payment model to represent upcoming payments
struct Payment: Identifiable {
    let id: UUID
    let amount: Double
    let dueDate: Date
    let description: String
    let assignedTo: String
    let isPaid: Bool
    
    init(id: UUID = UUID(), amount: Double, dueDate: Date, description: String, assignedTo: String, isPaid: Bool = false) {
        self.id = id
        self.amount = amount
        self.dueDate = dueDate
        self.description = description
        self.assignedTo = assignedTo
        self.isPaid = isPaid
    }
}

// Issue model to represent user created issues
struct Issue: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let createdDate: Date
    let status: IssueStatus
    let createdBy: String
    
    init(id: UUID = UUID(), title: String, description: String, createdDate: Date = Date(), status: IssueStatus = .open, createdBy: String) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.status = status
        self.createdBy = createdBy
    }
}

enum IssueStatus: String, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
}

// Video model to represent uploaded videos
struct Video: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let uploadDate: Date
    let duration: TimeInterval
    let url: URL?
    let uploadStatus: UploadStatus
    
    init(id: UUID = UUID(), title: String, description: String, uploadDate: Date = Date(), duration: TimeInterval = 0, url: URL? = nil, uploadStatus: UploadStatus = .notStarted) {
        self.id = id
        self.title = title
        self.description = description
        self.uploadDate = uploadDate
        self.duration = duration
        self.url = url
        self.uploadStatus = uploadStatus
    }
}

enum UploadStatus: String {
    case notStarted = "Not Started"
    case uploading = "Uploading"
    case completed = "Completed"
    case failed = "Failed"
}

// History item model to represent user activity history
struct HistoryItem: Identifiable {
    let id: UUID
    let activityType: ActivityType
    let description: String
    let date: Date
    let relatedItemId: UUID?
    
    init(id: UUID = UUID(), activityType: ActivityType, description: String, date: Date = Date(), relatedItemId: UUID? = nil) {
        self.id = id
        self.activityType = activityType
        self.description = description
        self.date = date
        self.relatedItemId = relatedItemId
    }
}

enum ActivityType: String {
    case payment = "Payment"
    case issue = "Issue"
    case videoUpload = "Video Upload"
}