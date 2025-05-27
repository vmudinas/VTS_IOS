import Foundation

// Message model to represent communication between landlord and tenant
struct Message: Identifiable {
    let id: UUID
    let sender: String
    let recipient: String
    let content: String
    let timestamp: Date
    var isRead: Bool
    var attachmentURLs: [URL]?
    
    init(id: UUID = UUID(), sender: String, recipient: String, content: String, timestamp: Date = Date(), isRead: Bool = false, attachmentURLs: [URL]? = nil) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.attachmentURLs = attachmentURLs
    }
}

// Payment method enum to represent different payment options
enum PaymentMethod: String, CaseIterable {
    case stripe = "Stripe"
    case paypal = "PayPal"
    case applePay = "Apple Pay"
    case bankTransfer = "Bank Transfer"
}

// Payment category for financial reporting
enum PaymentCategory: String, CaseIterable {
    // Income categories
    case rent = "Rent Income"
    case deposit = "Security Deposit"
    case fee = "Fees Income"
    case other = "Other Income"
    
    // Expense categories
    case maintenance = "Maintenance"
    case utilities = "Utilities"
    case insurance = "Insurance"
    case tax = "Taxes"
    case refund = "Refund"
    case service = "Services"
    case management = "Management"
    case expense = "Other Expense"
    
    // Check if this is an income or expense category
    var isIncome: Bool {
        switch self {
        case .rent, .deposit, .fee, .other:
            return true
        default:
            return false
        }
    }
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
    var refundIssuedBy: String? // Who issued the refund (landlord ID)
    var refundReason: String? // Reason for refund
    var refundDate: Date? // When the refund was issued
    var nextDueDate: Date?
    var category: PaymentCategory? // Category for financial reporting
    
    init(id: UUID = UUID(), amount: Double, dueDate: Date, description: String, assignedTo: String, isPaid: Bool = false, paymentMethod: PaymentMethod? = nil, isRecurring: Bool = false, paymentFrequency: PaymentFrequency = .oneTime, hasRefund: Bool = false, refundAmount: Double? = nil, refundIssuedBy: String? = nil, refundReason: String? = nil, refundDate: Date? = nil, nextDueDate: Date? = nil, category: PaymentCategory? = nil) {
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
        self.refundIssuedBy = refundIssuedBy
        self.refundReason = refundReason
        self.refundDate = refundDate
        self.nextDueDate = nextDueDate
        self.category = category
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
    case document = "Document"
    case message = "Message"
}

// Document type enum to represent different kinds of documents
enum DocumentType: String, CaseIterable {
    case lease = "Lease Agreement"
    case moveInChecklist = "Move-in Checklist"
    case renewalAgreement = "Renewal Agreement"
    case other = "Other Document"
}

// Document signature status
enum SignatureStatus: String {
    case notRequired = "Not Required"
    case pending = "Signature Pending"
    case completed = "Signed"
    case rejected = "Rejected"
}

// Document model to represent uploaded documents
struct Document: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let documentType: DocumentType
    let uploadDate: Date
    let fileURL: URL?
    var signatureStatus: SignatureStatus
    var signedDate: Date?
    var signedBy: String?
    var relatedEntityId: String? // could be property ID, tenant ID, etc.
    
    init(id: UUID = UUID(), title: String, description: String, documentType: DocumentType, uploadDate: Date = Date(), fileURL: URL? = nil, signatureStatus: SignatureStatus = .notRequired, signedDate: Date? = nil, signedBy: String? = nil, relatedEntityId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.documentType = documentType
        self.uploadDate = uploadDate
        self.fileURL = fileURL
        self.signatureStatus = signatureStatus
        self.signedDate = signedDate
        self.signedBy = signedBy
        self.relatedEntityId = relatedEntityId
    }
}