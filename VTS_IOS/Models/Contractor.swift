import Foundation

struct Contractor: Identifiable, Codable {
    let id: UUID
    let name: String
    let company: String
    let specialties: [ContractorSpecialty]
    let email: String
    let phone: String
    var hourlyRate: Double?
    var isPreferred: Bool
    var rating: Int?
    
    init(
        id: UUID = UUID(),
        name: String,
        company: String,
        specialties: [ContractorSpecialty],
        email: String,
        phone: String,
        hourlyRate: Double? = nil,
        isPreferred: Bool = false,
        rating: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.company = company
        self.specialties = specialties
        self.email = email
        self.phone = phone
        self.hourlyRate = hourlyRate
        self.isPreferred = isPreferred
        self.rating = rating
    }
}

enum ContractorSpecialty: String, Codable, CaseIterable {
    case plumbing = "Plumbing"
    case electrical = "Electrical"
    case hvac = "HVAC"
    case general = "General Maintenance"
    case carpentry = "Carpentry"
    case painting = "Painting"
    case landscaping = "Landscaping"
    case cleaning = "Cleaning"
}