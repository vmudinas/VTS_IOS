import Foundation

struct Document: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let documentType: DocumentType
    let uploadDate: Date
    let fileURL: URL?
    var signatureStatus: SignatureStatus
    var signedDate: Date?
    var signedBy: String?
    var relatedEntityId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        documentType: DocumentType,
        fileURL: URL? = nil,
        uploadDate: Date = Date(),
        signatureStatus: SignatureStatus = .notRequired,
        signedDate: Date? = nil,
        signedBy: String? = nil,
        relatedEntityId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.documentType = documentType
        self.fileURL = fileURL
        self.uploadDate = uploadDate
        self.signatureStatus = signatureStatus
        self.signedDate = signedDate
        self.signedBy = signedBy
        self.relatedEntityId = relatedEntityId
    }
}

enum DocumentType: String, Codable, CaseIterable {
    case lease = "Lease Agreement"
    case moveInChecklist = "Move-in Checklist"
    case renewalAgreement = "Renewal Agreement"
    case other = "Other"
}

enum SignatureStatus: String, Codable, CaseIterable {
    case notRequired = "No Signature Required"
    case pending = "Signature Needed"
    case completed = "Signed"
    case rejected = "Rejected"
}