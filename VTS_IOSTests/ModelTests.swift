import XCTest
@testable import VTS_IOS

class ModelTests: XCTestCase {
    
    // Test Issue model
    func testIssueModel() {
        // Given
        let id = UUID()
        let title = "Test Issue"
        let description = "Test Description"
        let createdDate = Date()
        let status = IssueStatus.open
        let createdBy = "test_user"
        let priority = IssuePriority.high
        let assignedTo = "staff_member"
        let imageURLs = [URL(string: "https://example.com/image.jpg")!]
        let isRecurring = true
        let recurringFrequency = PaymentFrequency.monthly
        let nextDueDate = Date().addingTimeInterval(86400 * 30) // 30 days later
        let contractorId = UUID()
        let estimatedCost = 100.0
        let actualCost = 95.0
        let completionDate = Date().addingTimeInterval(86400 * 7) // 7 days later
        let skipNextOccurrence = false
        let notes = "Test notes"
        let propertyId = UUID()
        
        // When
        let issue = Issue(
            id: id,
            title: title,
            description: description,
            createdDate: createdDate,
            status: status,
            createdBy: createdBy,
            priority: priority,
            assignedTo: assignedTo,
            imageURLs: imageURLs,
            isRecurring: isRecurring,
            recurringFrequency: recurringFrequency,
            nextDueDate: nextDueDate,
            contractorId: contractorId,
            estimatedCost: estimatedCost,
            actualCost: actualCost,
            completionDate: completionDate,
            skipNextOccurrence: skipNextOccurrence,
            notes: notes,
            propertyId: propertyId
        )
        
        // Then
        XCTAssertEqual(issue.id, id)
        XCTAssertEqual(issue.title, title)
        XCTAssertEqual(issue.description, description)
        XCTAssertEqual(issue.createdDate, createdDate)
        XCTAssertEqual(issue.status, status)
        XCTAssertEqual(issue.createdBy, createdBy)
        XCTAssertEqual(issue.priority, priority)
        XCTAssertEqual(issue.assignedTo, assignedTo)
        XCTAssertEqual(issue.imageURLs, imageURLs)
        XCTAssertEqual(issue.isRecurring, isRecurring)
        XCTAssertEqual(issue.recurringFrequency, recurringFrequency)
        XCTAssertEqual(issue.nextDueDate, nextDueDate)
        XCTAssertEqual(issue.contractorId, contractorId)
        XCTAssertEqual(issue.estimatedCost, estimatedCost)
        XCTAssertEqual(issue.actualCost, actualCost)
        XCTAssertEqual(issue.completionDate, completionDate)
        XCTAssertEqual(issue.skipNextOccurrence, skipNextOccurrence)
        XCTAssertEqual(issue.notes, notes)
        XCTAssertEqual(issue.propertyId, propertyId)
    }
    
    // Test IssuePriority estimatedResponseTime
    func testIssuePriorityEstimatedResponseTime() {
        XCTAssertEqual(IssuePriority.low.estimatedResponseTime, "Within 7 days")
        XCTAssertEqual(IssuePriority.medium.estimatedResponseTime, "Within 3 days")
        XCTAssertEqual(IssuePriority.high.estimatedResponseTime, "Within 24 hours")
        XCTAssertEqual(IssuePriority.urgent.estimatedResponseTime, "Within 4 hours")
    }
    
    // Test Contractor model
    func testContractorModel() {
        // Given
        let id = UUID()
        let name = "John Smith"
        let company = "ABC Contractors"
        let specialties = [ContractorSpecialty.plumbing, ContractorSpecialty.electrical]
        let email = "john@example.com"
        let phone = "555-1234"
        let hourlyRate = 75.0
        let isPreferred = true
        let rating = 5
        
        // When
        let contractor = Contractor(
            id: id,
            name: name,
            company: company,
            specialties: specialties,
            email: email,
            phone: phone,
            hourlyRate: hourlyRate,
            isPreferred: isPreferred,
            rating: rating
        )
        
        // Then
        XCTAssertEqual(contractor.id, id)
        XCTAssertEqual(contractor.name, name)
        XCTAssertEqual(contractor.company, company)
        XCTAssertEqual(contractor.specialties, specialties)
        XCTAssertEqual(contractor.email, email)
        XCTAssertEqual(contractor.phone, phone)
        XCTAssertEqual(contractor.hourlyRate, hourlyRate)
        XCTAssertEqual(contractor.isPreferred, isPreferred)
        XCTAssertEqual(contractor.rating, rating)
    }
    
    // Test payment model
    func testPaymentModel() {
        // Given
        let id = UUID()
        let amount = 100.0
        let dueDate = Date()
        let description = "Test Payment"
        let assignedTo = "user123"
        let isPaid = false
        let paymentMethod = PaymentMethod.stripe
        let isRecurring = true
        let paymentFrequency = PaymentFrequency.monthly
        let hasRefund = false
        let category = PaymentCategory.fee
        
        // When
        let payment = Payment(
            id: id,
            amount: amount,
            dueDate: dueDate,
            description: description,
            assignedTo: assignedTo,
            isPaid: isPaid,
            paymentMethod: paymentMethod,
            isRecurring: isRecurring,
            paymentFrequency: paymentFrequency,
            hasRefund: hasRefund,
            category: category
        )
        
        // Then
        XCTAssertEqual(payment.id, id)
        XCTAssertEqual(payment.amount, amount)
        XCTAssertEqual(payment.dueDate, dueDate)
        XCTAssertEqual(payment.description, description)
        XCTAssertEqual(payment.assignedTo, assignedTo)
        XCTAssertEqual(payment.isPaid, isPaid)
        XCTAssertEqual(payment.paymentMethod, paymentMethod)
        XCTAssertEqual(payment.isRecurring, isRecurring)
        XCTAssertEqual(payment.paymentFrequency, paymentFrequency)
        XCTAssertEqual(payment.hasRefund, hasRefund)
        XCTAssertEqual(payment.category, category)
    }
    
    // Test PaymentCategory isIncome property
    func testPaymentCategoryIsIncome() {
        // Income categories
        XCTAssertTrue(PaymentCategory.rent.isIncome)
        XCTAssertTrue(PaymentCategory.deposit.isIncome)
        XCTAssertTrue(PaymentCategory.fee.isIncome)
        XCTAssertTrue(PaymentCategory.other.isIncome)
        
        // Expense categories
        XCTAssertFalse(PaymentCategory.maintenance.isIncome)
        XCTAssertFalse(PaymentCategory.utilities.isIncome)
        XCTAssertFalse(PaymentCategory.insurance.isIncome)
        XCTAssertFalse(PaymentCategory.tax.isIncome)
        XCTAssertFalse(PaymentCategory.refund.isIncome)
        XCTAssertFalse(PaymentCategory.service.isIncome)
        XCTAssertFalse(PaymentCategory.management.isIncome)
        XCTAssertFalse(PaymentCategory.expense.isIncome)
    }
}