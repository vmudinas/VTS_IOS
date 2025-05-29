import Foundation

enum PaymentFrequency: String, Codable, CaseIterable {
    case oneTime = "One-time"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
}