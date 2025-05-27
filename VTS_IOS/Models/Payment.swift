import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    let amount: Double
    var dueDate: Date
    let description: String
    var isPaid: Bool
    var paymentMethod: PaymentMethod?
    var isRecurring: Bool
    var paymentFrequency: PaymentFrequency
    var nextDueDate: Date?
    var hasRefund: Bool
    var refundAmount: Double?
    var refundIssuedBy: String?
    var refundReason: String?
    var refundDate: Date?
    let assignedTo: String?
    var category: PaymentCategory?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        dueDate: Date,
        description: String,
        assignedTo: String? = nil,
        isPaid: Bool = false,
        paymentMethod: PaymentMethod? = nil,
        isRecurring: Bool = false,
        paymentFrequency: PaymentFrequency = .oneTime,
        nextDueDate: Date? = nil,
        hasRefund: Bool = false,
        refundAmount: Double? = nil,
        refundIssuedBy: String? = nil,
        refundReason: String? = nil,
        refundDate: Date? = nil,
        category: PaymentCategory? = nil
    ) {
        self.id = id
        self.amount = amount
        self.dueDate = dueDate
        self.description = description
        self.assignedTo = assignedTo
        self.isPaid = isPaid
        self.paymentMethod = paymentMethod
        self.isRecurring = isRecurring
        self.paymentFrequency = paymentFrequency
        self.nextDueDate = nextDueDate
        self.hasRefund = hasRefund
        self.refundAmount = refundAmount
        self.refundIssuedBy = refundIssuedBy
        self.refundReason = refundReason
        self.refundDate = refundDate
        self.category = category
    }
}

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case paypal = "PayPal"
    case stripe = "Stripe"
    case cash = "Cash"
    case check = "Check"
    case other = "Other"
}

enum PaymentFrequency: String, Codable, CaseIterable {
    case oneTime = "One-time"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
}

enum PaymentCategory: String, Codable, CaseIterable {
    case rent = "Rent"
    case utilities = "Utilities"
    case maintenance = "Maintenance"
    case insurance = "Insurance"
    case taxes = "Taxes"
    case mortgage = "Mortgage"
    case services = "Services"
    case management = "Management"
    case other = "Other"
    
    var isIncome: Bool {
        switch self {
        case .rent, .services, .management:
            return true
        case .utilities, .maintenance, .insurance, .taxes, .mortgage, .other:
            return false
        }
    }
}