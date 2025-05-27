import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let sender: String
    let recipient: String
    let content: String
    let timestamp: Date
    var isRead: Bool
    var replyToMessageId: UUID?
    var attachmentURLs: [URL]?
    
    init(
        id: UUID = UUID(),
        sender: String,
        recipient: String,
        content: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        replyToMessageId: UUID? = nil,
        attachmentURLs: [URL]? = nil
    ) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.replyToMessageId = replyToMessageId
        self.attachmentURLs = attachmentURLs
    }
}