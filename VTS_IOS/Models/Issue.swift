import Foundation

struct Issue: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let createdDate: Date
    var status: IssueStatus
    let createdBy: String
    var priority: IssuePriority
    var assignedTo: String?
    var completionDate: Date?
    var notes: String?
    var imageURLs: [URL]
    var estimatedCost: Double?
    var actualCost: Double?
    var contractorId: UUID?
    var isRecurring: Bool
    var recurringFrequency: PaymentFrequency
    var nextDueDate: Date?
    var skipNextOccurrence: Bool
    var propertyId: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        createdDate: Date = Date(),
        status: IssueStatus = .open,
        createdBy: String,
        priority: IssuePriority = .medium,
        assignedTo: String? = nil,
        completionDate: Date? = nil,
        notes: String? = nil,
        imageURLs: [URL] = [],
        estimatedCost: Double? = nil,
        actualCost: Double? = nil,
        contractorId: UUID? = nil,
        isRecurring: Bool = false,
        recurringFrequency: PaymentFrequency = .monthly,
        nextDueDate: Date? = nil,
        skipNextOccurrence: Bool = false,
        propertyId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.status = status
        self.createdBy = createdBy
        self.priority = priority
        self.assignedTo = assignedTo
        self.completionDate = completionDate
        self.notes = notes
        self.imageURLs = imageURLs
        self.estimatedCost = estimatedCost
        self.actualCost = actualCost
        self.contractorId = contractorId
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.nextDueDate = nextDueDate
        self.skipNextOccurrence = skipNextOccurrence
        self.propertyId = propertyId
    }
}

enum IssueStatus: String, Codable, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
}

enum IssuePriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var estimatedResponseTime: String {
        switch self {
        case .low:
            return "5-7 business days"
        case .medium:
            return "2-4 business days"
        case .high:
            return "24-48 hours"
        case .urgent:
            return "ASAP (4-8 hours)"
        }
    }
}