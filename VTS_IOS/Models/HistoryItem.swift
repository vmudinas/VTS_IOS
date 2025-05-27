import Foundation

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let activityType: ActivityType
    let description: String
    let date: Date
    var relatedItemId: UUID?
    
    init(id: UUID = UUID(), activityType: ActivityType, description: String, date: Date = Date(), relatedItemId: UUID? = nil) {
        self.id = id
        self.activityType = activityType
        self.description = description
        self.date = date
        self.relatedItemId = relatedItemId
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case payment = "Payment"
    case issue = "Maintenance"
    case document = "Document"
    case message = "Message"
    case videoUpload = "Video"
    case property = "Property"
}