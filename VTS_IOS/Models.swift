import Foundation

// Payment method enum to represent different payment options
enum PaymentMethod: String, CaseIterable {
    case stripe = "Stripe"
    case paypal = "PayPal"
    case applePay = "Apple Pay"
    case bankTransfer = "Bank Transfer"
}

// Payment frequency for recurring payments
enum PaymentFrequency: String, CaseIterable {
    case oneTime = "One Time"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
}

// Payment model to represent upcoming payments
struct Payment: Identifiable {
    let id: UUID
    let amount: Double
    let dueDate: Date
    let description: String
    let assignedTo: String
    let isPaid: Bool
    var paymentMethod: PaymentMethod?
    var isRecurring: Bool
    var paymentFrequency: PaymentFrequency
    var hasRefund: Bool
    var refundAmount: Double?
    var nextDueDate: Date?
    
    init(id: UUID = UUID(), amount: Double, dueDate: Date, description: String, assignedTo: String, isPaid: Bool = false, paymentMethod: PaymentMethod? = nil, isRecurring: Bool = false, paymentFrequency: PaymentFrequency = .oneTime, hasRefund: Bool = false, refundAmount: Double? = nil, nextDueDate: Date? = nil) {
        self.id = id
        self.amount = amount
        self.dueDate = dueDate
        self.description = description
        self.assignedTo = assignedTo
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
        self.isRecurring = isRecurring
        self.paymentFrequency = paymentFrequency
        self.hasRefund = hasRefund
        self.refundAmount = refundAmount
        self.nextDueDate = nextDueDate
    }
}

// Priority level for maintenance requests
enum IssuePriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}

// Issue model to represent user created issues and maintenance requests
struct Issue: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let createdDate: Date
    let status: IssueStatus
    let createdBy: String
    var priority: IssuePriority
    var assignedTo: String?
    var imageURLs: [URL]
    var isRecurring: Bool
    var recurringFrequency: PaymentFrequency
    var nextDueDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String, createdDate: Date = Date(), status: IssueStatus = .open, createdBy: String, priority: IssuePriority = .medium, assignedTo: String? = nil, imageURLs: [URL] = [], isRecurring: Bool = false, recurringFrequency: PaymentFrequency = .oneTime, nextDueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.status = status
        self.createdBy = createdBy
        self.priority = priority
        self.assignedTo = assignedTo
        self.imageURLs = imageURLs
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.nextDueDate = nextDueDate
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