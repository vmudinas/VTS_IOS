import XCTest
@testable import VTS_IOS

class ServiceIntegrationTests: XCTestCase {
    
    var issueService: IssueService!
    var contractorService: ContractorService!
    var historyService: HistoryService!
    
    override func setUp() {
        super.setUp()
        historyService = HistoryService()
        issueService = IssueService(historyService: historyService)
        contractorService = ContractorService(historyService: historyService)
        
        // Start with a clean slate for each test
        issueService.issues = []
        contractorService.contractors = []
        historyService.historyItems = []
        
        // Add sample contractors for testing
        contractorService.contractors = [
            Contractor(
                id: UUID(),
                name: "John Smith",
                company: "Smith Plumbing",
                specialties: [.plumbing],
                email: "john@example.com",
                phone: "555-1234",
                hourlyRate: 75.0,
                isPreferred: true,
                rating: 5
            ),
            Contractor(
                id: UUID(),
                name: "Jane Doe",
                company: "Doe Electrical",
                specialties: [.electrical],
                email: "jane@example.com",
                phone: "555-5678",
                hourlyRate: 85.0,
                isPreferred: true,
                rating: 4
            )
        ]
    }
    
    override func tearDown() {
        issueService = nil
        contractorService = nil
        historyService = nil
        super.tearDown()
    }
    
    // Test complete issue workflow
    func testIssueWorkflow() {
        // 1. Create a new issue
        issueService.createIssue(
            title: "Leaking faucet",
            description: "The bathroom faucet is leaking",
            priority: .medium
        )
        
        // Verify issue was created
        XCTAssertEqual(issueService.issues.count, 1)
        XCTAssertEqual(issueService.issues[0].title, "Leaking faucet")
        
        let issue = issueService.issues[0]
        
        // 2. Assign staff to the issue
        issueService.assignIssue(issue: issue, to: "maintenance_staff_1")
        XCTAssertEqual(issueService.issues[0].assignedTo, "maintenance_staff_1")
        
        // 3. Assign contractor to the issue
        let contractor = contractorService.contractors.first!
        issueService.assignContractor(issue: issue, contractorId: contractor.id)
        XCTAssertEqual(issueService.issues[0].contractorId, contractor.id)
        
        // 4. Update estimated cost
        issueService.updateCosts(issue: issue, estimatedCost: 50.0, actualCost: nil)
        XCTAssertEqual(issueService.issues[0].estimatedCost, 50.0)
        
        // 5. Update status to in progress
        issueService.updateIssueStatus(issue: issue, status: .inProgress)
        XCTAssertEqual(issueService.issues[0].status, .inProgress)
        
        // 6. Add notes
        issueService.addNotes(issue: issue, notes: "Ordered replacement parts")
        XCTAssertEqual(issueService.issues[0].notes, "Ordered replacement parts")
        
        // 7. Add images
        let imageUrl = URL(string: "https://example.com/faucet.jpg")!
        issueService.addImagesToIssue(issue: issue, imageURLs: [imageUrl])
        XCTAssertEqual(issueService.issues[0].imageURLs.count, 1)
        
        // 8. Update with actual cost and completion
        issueService.updateCosts(issue: issueService.issues[0], estimatedCost: 50.0, actualCost: 55.75)
        XCTAssertEqual(issueService.issues[0].actualCost, 55.75)
        
        // 9. Complete the issue
        issueService.completeIssue(issue: issueService.issues[0], actualCost: 55.75)
        XCTAssertEqual(issueService.issues[0].status, .resolved)
        XCTAssertNotNil(issueService.issues[0].completionDate)
    }
    
    // Test recurring maintenance workflow
    func testRecurringMaintenanceWorkflow() {
        // 1. Create a recurring maintenance issue
        issueService.createIssue(
            title: "Monthly pest control",
            description: "Regular pest control service",
            priority: .medium,
            isRecurring: true,
            recurringFrequency: .monthly
        )
        
        // Verify issue was created with recurring properties
        XCTAssertEqual(issueService.issues.count, 1)
        XCTAssertTrue(issueService.issues[0].isRecurring)
        XCTAssertEqual(issueService.issues[0].recurringFrequency, .monthly)
        XCTAssertNotNil(issueService.issues[0].nextDueDate)
        
        let issue = issueService.issues[0]
        
        // 2. Assign contractor
        let contractor = contractorService.contractors.first!
        issueService.assignContractor(issue: issue, contractorId: contractor.id)
        
        // 3. Mark as completed
        issueService.updateIssueStatus(issue: issue, status: .resolved)
        
        // Verify that a new recurring issue was created
        XCTAssertEqual(issueService.issues.count, 2)
        XCTAssertEqual(issueService.issues[0].status, .resolved)
        XCTAssertEqual(issueService.issues[1].status, .open)
        
        // The new issue should have the same title and be recurring
        XCTAssertEqual(issueService.issues[1].title, issue.title)
        XCTAssertEqual(issueService.issues[1].isRecurring, true)
        
        // The contractor should be assigned to the new issue as well
        XCTAssertEqual(issueService.issues[1].contractorId, contractor.id)
    }
    
    // Test the skip functionality for recurring maintenance
    func testSkipRecurringMaintenance() {
        // 1. Create a recurring maintenance issue
        issueService.createIssue(
            title: "Quarterly HVAC maintenance",
            description: "Regular HVAC maintenance",
            priority: .medium,
            isRecurring: true,
            recurringFrequency: .quarterly
        )
        
        let issue = issueService.issues[0]
        let originalNextDueDate = issue.nextDueDate
        
        // 2. Skip the next occurrence
        issueService.skipNextOccurrence(issue: issue)
        
        // Verify the issue is marked to skip next occurrence
        XCTAssertTrue(issueService.issues[0].skipNextOccurrence)
        
        // Verify the next due date was updated (should be moved forward by one quarter)
        if let originalDate = originalNextDueDate, let newDate = issueService.issues[0].nextDueDate {
            // For quarterly frequency, the new date should be roughly 3 months later than the initial date
            let calendar = Calendar.current
            let expectedDate = calendar.date(byAdding: .month, value: 3, to: originalDate)!
            
            // Allow some tolerance for date calculations
            let tolerance: TimeInterval = 60 * 60 * 24 // One day in seconds
            XCTAssertLessThanOrEqual(abs(newDate.timeIntervalSince(expectedDate)), tolerance)
        } else {
            XCTFail("Next due date should not be nil")
        }
        
        // 3. Resolve the issue
        issueService.updateIssueStatus(issue: issueService.issues[0], status: .resolved)
        
        // Since we marked it to skip, no new issue should be created
        XCTAssertEqual(issueService.issues.count, 1)
    }
    
    // Test contractor assignment and retrieval
    func testContractorIntegration() {
        // 1. Find contractors by specialty
        let plumbingContractors = contractorService.findContractors(specialty: .plumbing)
        XCTAssertEqual(plumbingContractors.count, 1)
        XCTAssertEqual(plumbingContractors[0].name, "John Smith")
        
        let electricalContractors = contractorService.findContractors(specialty: .electrical)
        XCTAssertEqual(electricalContractors.count, 1)
        XCTAssertEqual(electricalContractors[0].name, "Jane Doe")
        
        // 2. Find contractors by preferred status
        let preferredContractors = contractorService.findContractors(preferredOnly: true)
        XCTAssertEqual(preferredContractors.count, 2) // Both our test contractors are preferred
        
        // 3. Create issue and assign contractor
        issueService.createIssue(
            title: "Electrical problem",
            description: "Outlet not working",
            priority: .high
        )
        
        let issue = issueService.issues[0]
        let electrician = electricalContractors[0]
        
        issueService.assignContractor(issue: issue, contractorId: electrician.id)
        
        // 4. Retrieve contractor by ID
        let retrievedContractor = contractorService.getContractor(by: electrician.id)
        XCTAssertNotNil(retrievedContractor)
        XCTAssertEqual(retrievedContractor?.name, "Jane Doe")
        
        // 5. Verify the issue has the correct contractor assigned
        XCTAssertEqual(issueService.issues[0].contractorId, electrician.id)
    }
}