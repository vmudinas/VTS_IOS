import Foundation
import SwiftUI

class ContractorService: ObservableObject {
    @Published var contractors: [Contractor] = []
    
    init() {
        // Load sample data
        loadSampleContractors()
    }
    
    func loadSampleContractors() {
        contractors = [
            Contractor(
                name: "John Smith",
                company: "Smith Plumbing",
                specialties: [.plumbing],
                email: "john@smithplumbing.com",
                phone: "555-123-4567",
                hourlyRate: 75.0,
                isPreferred: true,
                rating: 5
            ),
            Contractor(
                name: "Emily Johnson",
                company: "Johnson Electrical",
                specialties: [.electrical],
                email: "emily@johnsonelectrical.com",
                phone: "555-234-5678",
                hourlyRate: 80.0,
                isPreferred: true,
                rating: 4
            ),
            Contractor(
                name: "Michael Brown",
                company: "Brown HVAC",
                specialties: [.hvac],
                email: "michael@brownhvac.com",
                phone: "555-345-6789",
                hourlyRate: 85.0,
                isPreferred: false,
                rating: 3
            ),
            Contractor(
                name: "Sarah Davis",
                company: "Davis General Maintenance",
                specialties: [.general, .carpentry],
                email: "sarah@davisgm.com",
                phone: "555-456-7890",
                hourlyRate: 65.0,
                isPreferred: true,
                rating: 5
            ),
            Contractor(
                name: "Robert Wilson",
                company: "Wilson Painting",
                specialties: [.painting],
                email: "robert@wilsonpainting.com",
                phone: "555-567-8901",
                hourlyRate: 60.0,
                isPreferred: false,
                rating: 4
            ),
            Contractor(
                name: "Jennifer Martinez",
                company: "Martinez Landscaping",
                specialties: [.landscaping],
                email: "jennifer@martinezlandscaping.com",
                phone: "555-678-9012",
                hourlyRate: 70.0,
                isPreferred: true,
                rating: 4
            ),
            Contractor(
                name: "David Thompson",
                company: "Thompson Cleaning",
                specialties: [.cleaning],
                email: "david@thompsoncleaning.com",
                phone: "555-789-0123",
                hourlyRate: 55.0,
                isPreferred: false,
                rating: 3
            ),
            Contractor(
                name: "Lisa Anderson",
                company: "Anderson General Services",
                specialties: [.general, .plumbing, .electrical],
                email: "lisa@andersonservices.com",
                phone: "555-890-1234",
                hourlyRate: 80.0,
                isPreferred: true,
                rating: 5
            )
        ]
    }
    
    func getContractor(by id: UUID) -> Contractor? {
        return contractors.first { $0.id == id }
    }
    
    func findContractors(specialty: ContractorSpecialty? = nil, preferredOnly: Bool = false) -> [Contractor] {
        var filtered = contractors
        
        if let specialty = specialty {
            filtered = filtered.filter { $0.specialties.contains(specialty) }
        }
        
        if preferredOnly {
            filtered = filtered.filter { $0.isPreferred }
        }
        
        return filtered
    }
    
    func addContractor(_ contractor: Contractor) {
        contractors.append(contractor)
    }
    
    func updateContractor(_ contractor: Contractor) {
        if let index = contractors.firstIndex(where: { $0.id == contractor.id }) {
            contractors[index] = contractor
        }
    }
    
    func setPreferred(contractorId: UUID, isPreferred: Bool) {
        if let index = contractors.firstIndex(where: { $0.id == contractorId }) {
            var contractor = contractors[index]
            contractor.isPreferred = isPreferred
            contractors[index] = contractor
        }
    }
    
    func rateContractor(contractorId: UUID, rating: Int) {
        guard (1...5).contains(rating) else { return }
        
        if let index = contractors.firstIndex(where: { $0.id == contractorId }) {
            var contractor = contractors[index]
            contractor.rating = rating
            contractors[index] = contractor
        }
    }
}