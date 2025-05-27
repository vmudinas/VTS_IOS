import Foundation

struct Property: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let description: String
    let latitude: Double
    let longitude: Double
    let createdDate: Date
    let createdBy: String
    var tenantEmail: String?
    var tenantPhone: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        description: String,
        latitude: Double,
        longitude: Double,
        createdDate: Date = Date(),
        createdBy: String,
        tenantEmail: String? = nil,
        tenantPhone: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.createdDate = createdDate
        self.createdBy = createdBy
        self.tenantEmail = tenantEmail
        self.tenantPhone = tenantPhone
    }
}