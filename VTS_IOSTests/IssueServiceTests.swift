import XCTest
@testable import VTS_IOS

class IssueServiceTests: XCTestCase {
    
    var issueService: IssueService!
    
    override func setUp() {
        super.setUp()
        issueService = IssueService()
        // Start with a clean state for each test
        issueService.issues = []
    }
    
    override func tearDown() {
        issueService = nil
        super.tearDown()
    }
    
    func testCreateIssue() {
        // Given
        let title = "Test Issue"
        let description = "Test Description"
        let priority = IssuePriority.high
        
        // When
        issueService.createIssue(
            title: title,
            description: description,
            priority: priority
        )
        
        // Then
        XCTAssertEqual(issueService.issues.count, 1)
        XCTAssertEqual(issueService.issues[0].title, title)
        XCTAssertEqual(issueService.issues[0].description, description)
        XCTAssertEqual(issueService.issues[0].priority, priority)
        XCTAssertEqual(issueService.issues[0].status, IssueStatus.open)
    }
    
    func testCreateRecurringIssue() {
        // Given
        let title = "Recurring Test Issue"
        let description = "Recurring Test Description"
        let isRecurring = true
        let frequency = PaymentFrequency.monthly
        
        // When
        issueService.createIssue(
            title: title,
            description: description,
            isRecurring: isRecurring,
            recurringFrequency: frequency
        )
        
        // Then
        XCTAssertEqual(issueService.issues.count, 1)
        XCTAssertEqual(issueService.issues[0].title, title)
        XCTAssertEqual(issueService.issues[0].isRecurring, true)
        XCTAssertEqual(issueService.issues[0].recurringFrequency, frequency)
        XCTAssertNotNil(issueService.issues[0].nextDueDate)
    }
    
    func testAssignIssue() {
        // Given
        let assignee = "test_user"
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        
        // When
        issueService.assignIssue(issue: issue, to: assignee)
        
        // Then
        XCTAssertEqual(issueService.issues[0].assignedTo, assignee)
    }
    
    func testUpdateIssueStatus() {
        // Given
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        let newStatus = IssueStatus.inProgress
        
        // When
        issueService.updateIssueStatus(issue: issue, status: newStatus)
        
        // Then
        XCTAssertEqual(issueService.issues[0].status, newStatus)
    }
    
    func testUpdateRecurringIssueToCompleted() {
        // Given
        issueService.createIssue(
            title: "Recurring Test Issue",
            description: "Recurring Test Description",
            isRecurring: true,
            recurringFrequency: .monthly
        )
        let initialIssue = issueService.issues[0]
        let initialNextDueDate = initialIssue.nextDueDate
        
        // When
        issueService.updateIssueStatus(issue: initialIssue, status: .resolved)
        
        // Then
        // There should now be two issues - the completed one and the next scheduled one
        XCTAssertEqual(issueService.issues.count, 2)
        XCTAssertEqual(issueService.issues[0].status, .resolved)
        XCTAssertEqual(issueService.issues[1].status, .open)
        XCTAssertEqual(issueService.issues[1].title, initialIssue.title)
        XCTAssertEqual(issueService.issues[1].description, initialIssue.description)
        XCTAssertEqual(issueService.issues[1].isRecurring, true)
        
        // The next due date for the new issue should be the initial next due date
        if let initialDate = initialNextDueDate {
            XCTAssertEqual(issueService.issues[1].createdDate, initialDate)
        }
    }
    
    func testAddImagesToIssue() {
        // Given
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        let mockImageURLs = [
            URL(string: "https://example.com/image1.jpg")!,
            URL(string: "https://example.com/image2.jpg")!
        ]
        
        // When
        issueService.addImagesToIssue(issue: issue, imageURLs: mockImageURLs)
        
        // Then
        XCTAssertEqual(issueService.issues[0].imageURLs.count, 2)
        XCTAssertEqual(issueService.issues[0].imageURLs, mockImageURLs)
    }
    
    func testAssignContractor() {
        // Given
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        let contractorId = UUID()
        
        // When
        issueService.assignContractor(issue: issue, contractorId: contractorId)
        
        // Then
        XCTAssertEqual(issueService.issues[0].contractorId, contractorId)
    }
    
    func testUpdateCosts() {
        // Given
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        let estimatedCost = 100.0
        let actualCost = 95.5
        
        // When
        issueService.updateCosts(issue: issue, estimatedCost: estimatedCost, actualCost: actualCost)
        
        // Then
        XCTAssertEqual(issueService.issues[0].estimatedCost, estimatedCost)
        XCTAssertEqual(issueService.issues[0].actualCost, actualCost)
    }
    
    func testAddNotes() {
        // Given
        issueService.createIssue(title: "Test Issue", description: "Test Description")
        let issue = issueService.issues[0]
        let notes = "Test note for the issue"
        
        // When
        issueService.addNotes(issue: issue, notes: notes)
        
        // Then
        XCTAssertEqual(issueService.issues[0].notes, notes)
        
        // Test append to existing notes
        let additionalNotes = "Additional test notes"
        issueService.addNotes(issue: issueService.issues[0], notes: additionalNotes)
        
        // Then
        XCTAssertTrue(issueService.issues[0].notes?.contains(notes) ?? false)
        XCTAssertTrue(issueService.issues[0].notes?.contains(additionalNotes) ?? false)
    }
    
    func testSkipNextOccurrence() {
        // Given
        issueService.createIssue(
            title: "Recurring Test Issue",
            description: "Recurring Test Description",
            isRecurring: true,
            recurringFrequency: .monthly
        )
        let issue = issueService.issues[0]
        let initialNextDueDate = issue.nextDueDate
        
        // When
        issueService.skipNextOccurrence(issue: issue)
        
        // Then
        XCTAssertTrue(issueService.issues[0].skipNextOccurrence)
        
        // The next due date should have been updated
        if let initialDate = initialNextDueDate, let newDate = issueService.issues[0].nextDueDate {
            // For monthly frequency, the new date should be roughly a month later than the initial date
            let calendar = Calendar.current
            let expectedMonth = calendar.date(byAdding: .month, value: 1, to: initialDate)!
            
            // Allow some tolerance for date calculations
            let tolerance: TimeInterval = 60 * 60 * 24 // One day in seconds
            XCTAssertLessThanOrEqual(abs(newDate.timeIntervalSince(expectedMonth)), tolerance)
        } else {
            XCTFail("Next due date should not be nil")
        }
    }
}