import Foundation

struct Video: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let uploadDate: Date
    var duration: TimeInterval
    var url: URL?
    var uploadStatus: UploadStatus
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        uploadDate: Date = Date(),
        duration: TimeInterval = 0,
        url: URL? = nil,
        uploadStatus: UploadStatus = .notStarted
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.uploadDate = uploadDate
        self.duration = duration
        self.url = url
        self.uploadStatus = uploadStatus
    }
}

enum UploadStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case uploading = "Uploading"
    case completed = "Completed"
    case failed = "Failed"
}