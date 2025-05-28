import Foundation
import Combine
import SwiftUI

// Mock service for handling payment data
class PaymentService: ObservableObject {
    @Published var upcomingPayments: [Payment] = []
    @Published var paymentHistory: [Payment] = []
    @Published var isOfflineMode: Bool = false
    
    let paymentGateway = PaymentGatewayService()
    private let persistence = PersistenceManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        // Load sample data
        loadSamplePayments()
        
        // Check connectivity
        checkConnectivity()
    }
    
    func checkConnectivity() {
        isOfflineMode = persistence.isOffline
    }
    
    func loadSamplePayments() {
        let calendar = Calendar.current
        
        upcomingPayments = [
            Payment(
                amount: 120.00,
                dueDate: calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                description: "Monthly service fee",
                assignedTo: "user123",
                isPaid: false,
                isRecurring: true,
                paymentFrequency: .monthly,
                nextDueDate: calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                category: .services
            ),
            Payment(
                amount: 85.50,
                dueDate: calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                description: "Equipment rental",
                assignedTo: "user123",
                isPaid: false,
                category: .other
            ),
            Payment(
                amount: 250.00,
                dueDate: calendar.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
                description: "Annual maintenance",
                assignedTo: "user123",
                isPaid: false,
                category: .maintenance
            )
        ]
        
        // Add some paid payments to history
        paymentHistory = [
            Payment(
                amount: 95.00,
                dueDate: calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                description: "Previous service fee",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .stripe,
                category: .services
            ),
            Payment(
                amount: 45.75,
                dueDate: calendar.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
                description: "Tool rental",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .paypal,
                hasRefund: true,
                refundAmount: 15.25,
                refundIssuedBy: "landlord123",
                refundReason: "Equipment returned early",
                refundDate: calendar.date(byAdding: .day, value: -18, to: Date()) ?? Date(),
                category: .other
            ),
            // Add more sample payments for financial reporting
            Payment(
                amount: 500.00,
                dueDate: calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
                description: "Monthly Rent - Unit 101",
                assignedTo: "landlord123",
                isPaid: true,
                paymentMethod: .bankTransfer,
                category: .rent
            ),
            Payment(
                amount: 45.00,
                dueDate: calendar.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
                description: "Water Bill",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .applePay,
                category: .utilities
            ),
            Payment(
                amount: 150.00,
                dueDate: calendar.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
                description: "Insurance Premium",
                assignedTo: "user123",
                isPaid: true,
                paymentMethod: .stripe,
                category: .insurance
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func fetchUpcomingPayments() {
        // Check connectivity first
        checkConnectivity()
        
        if isOfflineMode {
            // In offline mode, we'll use cached data
            print("Using cached payment data in offline mode")
        } else {
            // In a real app, this would be an API call
            // For this mock, we'll assume we got updated data
            
            // Schedule payment reminders for any upcoming payments
            for payment in upcomingPayments {
                notificationManager.schedulePaymentReminder(for: payment)
            }
        }
    }
    
    // Mark a payment as paid using the selected payment method
    func makePayment(payment: Payment, paymentMethod: PaymentMethod, completion: @escaping (Bool) -> Void) {
        var updatedPayment = payment
        updatedPayment.paymentMethod = paymentMethod
        
        paymentGateway.processPayment(payment: updatedPayment) { success in
            if success {
                if let index = self.upcomingPayments.firstIndex(where: { $0.id == payment.id }) {
                    var paidPayment = payment
                    paidPayment.isPaid = true
                    paidPayment.paymentMethod = paymentMethod
                    
                    self.upcomingPayments.remove(at: index)
                    self.paymentHistory.append(paidPayment)
                    self.paymentHistory.sort { $0.dueDate > $1.dueDate }
                    
                    // If recurring, add next payment to upcoming
                    if paidPayment.isRecurring, let nextDueDate = paidPayment.nextDueDate {
                        let nextPayment = Payment(
                            amount: paidPayment.amount,
                            dueDate: nextDueDate,
                            description: paidPayment.description,
                            assignedTo: paidPayment.assignedTo,
                            isPaid: false,
                            paymentMethod: paidPayment.paymentMethod,
                            isRecurring: true,
                            paymentFrequency: paidPayment.paymentFrequency,
                            nextDueDate: self.calculateNextDueDate(from: nextDueDate, frequency: paidPayment.paymentFrequency)
                        )
                        self.upcomingPayments.append(nextPayment)
                        self.upcomingPayments.sort { $0.dueDate < $1.dueDate }
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Process refund for a payment
    func refundPayment(payment: Payment, amount: Double, issuedBy: String, reason: String, completion: @escaping (Bool) -> Void) {
        paymentGateway.processRefund(payment: payment, amount: amount, issuedBy: issuedBy, reason: reason) { success, refundAmount, refundDate in
            if success {
                if let index = self.paymentHistory.firstIndex(where: { $0.id == payment.id }) {
                    var refundedPayment = payment
                    refundedPayment.hasRefund = true
                    refundedPayment.refundAmount = refundAmount
                    refundedPayment.refundIssuedBy = issuedBy
                    refundedPayment.refundReason = reason
                    refundedPayment.refundDate = refundDate
                    self.paymentHistory[index] = refundedPayment
                    
                    // Log the refund in history
                    let historyService = HistoryService()
                    historyService.addHistoryItem(item: HistoryItem(
                        activityType: .payment,
                        description: "Refund of $\(String(format: "%.2f", refundAmount)) issued for \(payment.description) by \(issuedBy). Reason: \(reason)",
                        relatedItemId: payment.id
                    ))
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // Set up recurring payment
    func setupRecurringPayment(payment: Payment, frequency: PaymentFrequency) {
        if let index = upcomingPayments.firstIndex(where: { $0.id == payment.id }) {
            let updatedPayment = paymentGateway.setupRecurringPayment(payment: payment, frequency: frequency)
            upcomingPayments[index] = updatedPayment
        }
    }
    
    // Calculate next due date based on frequency
    private func calculateNextDueDate(from date: Date, frequency: PaymentFrequency) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch frequency {
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
        case .annually:
            dateComponents.year = 1
        case .oneTime:
            return nil
        }
        
        return calendar.date(byAdding: dateComponents, to: date)
    }
    
    // MARK: - Financial Reporting Methods
    
    // Get all transactions for a date range
    func getTransactions(from startDate: Date, to endDate: Date) -> [Payment] {
        return paymentHistory.filter { payment in
            let date = payment.isPaid ? payment.dueDate : payment.dueDate
            return date >= startDate && date <= endDate
        }
    }
    
    // Calculate total income for a date range
    func calculateIncome(from startDate: Date, to endDate: Date) -> Double {
        let transactions = getTransactions(from: startDate, to: endDate)
        return transactions
            .filter { $0.category?.isIncome == true }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Calculate total expenses for a date range
    func calculateExpenses(from startDate: Date, to endDate: Date) -> Double {
        let transactions = getTransactions(from: startDate, to: endDate)
        return transactions
            .filter { $0.category?.isIncome == false }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Calculate profit/loss for a date range
    func calculateProfitLoss(from startDate: Date, to endDate: Date) -> Double {
        let income = calculateIncome(from: startDate, to: endDate)
        let expenses = calculateExpenses(from: startDate, to: endDate)
        return income - expenses
    }
    
    // Get income breakdown by category
    func incomeByCategory(from startDate: Date, to endDate: Date) -> [PaymentCategory: Double] {
        let transactions = getTransactions(from: startDate, to: endDate)
            .filter { $0.category?.isIncome == true }
        
        var result: [PaymentCategory: Double] = [:]
        
        for transaction in transactions {
            if let category = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result
    }
    
    // Get expenses breakdown by category
    func expensesByCategory(from startDate: Date, to endDate: Date) -> [PaymentCategory: Double] {
        let transactions = getTransactions(from: startDate, to: endDate)
            .filter { $0.category?.isIncome == false }
        
        var result: [PaymentCategory: Double] = [:]
        
        for transaction in transactions {
            if let category = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result
    }
    
    // Export data as CSV
    func exportToCSV(from startDate: Date, to endDate: Date) -> String {
        let transactions = getTransactions(from: startDate, to: endDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var csv = "Date,Description,Amount,Category,Type\n"
        
        for payment in transactions {
            let date = dateFormatter.string(from: payment.dueDate)
            let description = payment.description.replacingOccurrences(of: ",", with: ";")
            let amount = String(format: "%.2f", payment.amount)
            let category = payment.category?.rawValue ?? "Uncategorized"
            let type = payment.category?.isIncome == true ? "Income" : "Expense"
            
            csv += "\(date),\"\(description)\",\(amount),\"\(category)\",\(type)\n"
        }
        
        return csv
    }
}

// Mock service for handling issues and maintenance requests
class IssueService: ObservableObject {
    @Published var issues: [Issue] = []
    private let historyService = HistoryService()
    
    init() {
        // Load sample data
        loadSampleIssues()
    }
    
    func loadSampleIssues() {
        let contractorService = ContractorService()
        contractorService.loadSampleContractors()
        let contractors = contractorService.contractors
        
        issues = [
            Issue(
                title: "App crashes on startup",
                description: "The application sometimes crashes when starting on older devices",
                createdDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                status: .inProgress,
                createdBy: "user123"
            ),
            Issue(
                title: "Payment not processing",
                description: "Credit card payment fails with error code 402",
                createdDate: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                status: .open,
                createdBy: "user123"
            ),
            Issue(
                title: "Leaking kitchen faucet",
                description: "The kitchen faucet is leaking and needs repair",
                createdDate: Date().addingTimeInterval(-86400 * 1), // 1 day ago
                status: .open,
                createdBy: "tenant123",
                priority: .high,
                assignedTo: "maintenance1",
                imageURLs: [URL(string: "https://example.com/faucet1.jpg")!],
                isRecurring: false,
                contractorId: contractors.first(where: { $0.specialties.contains(.plumbing) })?.id,
                estimatedCost: 75.00,
                propertyId: UUID()
            ),
            Issue(
                title: "Monthly pest control",
                description: "Regular pest control service for the apartment",
                createdDate: Date().addingTimeInterval(-86400 * 10), // 10 days ago
                status: .inProgress,
                createdBy: "tenant123",
                priority: .medium,
                assignedTo: "contractor2",
                imageURLs: [],
                isRecurring: true,
                recurringFrequency: .monthly,
                nextDueDate: Date().addingTimeInterval(86400 * 20), // 20 days from now
                contractorId: contractors.last?.id,
                estimatedCost: 120.00,
                propertyId: UUID()
            ),
            Issue(
                title: "HVAC annual maintenance",
                description: "Scheduled annual maintenance for the HVAC system including filter replacement and system check",
                createdDate: Date().addingTimeInterval(-86400 * 15), // 15 days ago
                status: .resolved,
                createdBy: "admin",
                priority: .medium,
                assignedTo: nil,
                imageURLs: [],
                isRecurring: true,
                recurringFrequency: .annually,
                nextDueDate: Date().addingTimeInterval(86400 * 350), // About a year from now
                contractorId: contractors.first(where: { $0.specialties.contains(.hvac) })?.id,
                estimatedCost: 250.00,
                actualCost: 275.50,
                completionDate: Date().addingTimeInterval(-86400 * 2),
                notes: "Technician found dust build-up in the vents. Recommended more frequent filter changes.",
                propertyId: UUID()
            ),
            Issue(
                title: "Urgent electrical repair",
                description: "Power outage in Unit 203. Circuit breaker keeps tripping when appliances are used simultaneously.",
                createdDate: Date().addingTimeInterval(-86400 * 1), // 1 day ago
                status: .open,
                createdBy: "tenant203",
                priority: .urgent,
                assignedTo: nil,
                imageURLs: [],
                isRecurring: false,
                contractorId: contractors.first(where: { $0.specialties.contains(.electrical) })?.id,
                estimatedCost: 150.00,
                notes: "Tenant reported burning smell near electrical panel. Emergency service requested.",
                propertyId: UUID()
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func createIssue(title: String, description: String, priority: IssuePriority = .medium, imageURLs: [URL] = [], isRecurring: Bool = false, recurringFrequency: PaymentFrequency = .oneTime, estimatedCost: Double? = nil, propertyId: UUID? = nil) {
        let newIssue = Issue(
            title: title,
            description: description,
            createdBy: "user123",
            priority: priority,
            imageURLs: imageURLs,
            isRecurring: isRecurring,
            recurringFrequency: recurringFrequency,
            nextDueDate: isRecurring ? calculateNextDueDate(from: Date(), frequency: recurringFrequency) : nil,
            estimatedCost: estimatedCost,
            skipNextOccurrence: false,
            propertyId: propertyId
        )
        issues.append(newIssue)
        
        // Add to history
        let historyDescription = isRecurring 
            ? "Created recurring maintenance request: '\(title)'"
            : "Created maintenance request: '\(title)'"
        
        historyService.addHistoryItem(item: HistoryItem(
            activityType: .issue,
            description: historyDescription,
            relatedItemId: newIssue.id
        ))
        
        // In a real app, this would be sent to a backend API
    }
    
    // Assign an issue to someone
    func assignIssue(issue: Issue, to assignee: String) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            updatedIssue.assignedTo = assignee
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Maintenance request '\(issue.title)' assigned to \(assignee)",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Update the status of an issue
    func updateIssueStatus(issue: Issue, status: IssueStatus) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            let oldStatus = updatedIssue.status
            updatedIssue.status = status
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Maintenance request '\(issue.title)' status changed from \(oldStatus.rawValue) to \(status.rawValue)",
                relatedItemId: issue.id
            ))
            
            // If a recurring issue is resolved/closed, create the next occurrence
            if (status == .resolved || status == .closed) && 
               (oldStatus == .open || oldStatus == .inProgress) && 
               updatedIssue.isRecurring,
               let nextDueDate = updatedIssue.nextDueDate,
               !updatedIssue.skipNextOccurrence {
                
                let nextIssue = Issue(
                    title: updatedIssue.title,
                    description: updatedIssue.description,
                    createdDate: nextDueDate,
                    status: .open,
                    createdBy: updatedIssue.createdBy,
                    priority: updatedIssue.priority,
                    assignedTo: updatedIssue.assignedTo,
                    imageURLs: [],
                    isRecurring: true,
                    recurringFrequency: updatedIssue.recurringFrequency,
                    nextDueDate: calculateNextDueDate(from: nextDueDate, frequency: updatedIssue.recurringFrequency),
                    contractorId: updatedIssue.contractorId,
                    estimatedCost: updatedIssue.estimatedCost,
                    skipNextOccurrence: false,
                    propertyId: updatedIssue.propertyId
                )
                issues.append(nextIssue)
                
                // Add to history
                historyService.addHistoryItem(item: HistoryItem(
                    activityType: .issue,
                    description: "Next occurrence of recurring maintenance request '\(issue.title)' scheduled for \(formattedDate(nextDueDate))",
                    relatedItemId: nextIssue.id
                ))
            }
        }
    }
    
    // Add images to an existing issue
    func addImagesToIssue(issue: Issue, imageURLs: [URL]) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            updatedIssue.imageURLs.append(contentsOf: imageURLs)
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "\(imageURLs.count) photo(s) added to maintenance request '\(issue.title)'",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Add contractor to an issue
    func assignContractor(issue: Issue, contractorId: UUID) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            updatedIssue.contractorId = contractorId
            issues[index] = updatedIssue
            
            let contractorService = ContractorService()
            if let contractor = contractorService.getContractor(by: contractorId) {
                // Add to history
                historyService.addHistoryItem(item: HistoryItem(
                    activityType: .issue,
                    description: "Contractor '\(contractor.name)' from '\(contractor.company)' assigned to maintenance request '\(issue.title)'",
                    relatedItemId: issue.id
                ))
            }
        }
    }
    
    // Update cost estimates for an issue
    func updateCosts(issue: Issue, estimatedCost: Double?, actualCost: Double?) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            
            if let estimatedCost = estimatedCost {
                updatedIssue.estimatedCost = estimatedCost
            }
            
            if let actualCost = actualCost {
                updatedIssue.actualCost = actualCost
            }
            
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Updated cost information for maintenance request '\(issue.title)'",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Skip next occurrence of a recurring issue
    func skipNextOccurrence(issue: Issue) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }), issue.isRecurring {
            var updatedIssue = issue
            updatedIssue.skipNextOccurrence = true
            
            if let nextDueDate = updatedIssue.nextDueDate, let newNextDueDate = calculateNextDueDate(from: nextDueDate, frequency: updatedIssue.recurringFrequency) {
                updatedIssue.nextDueDate = newNextDueDate
            }
            
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Skipped next occurrence of recurring maintenance request '\(issue.title)'",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Add notes to an issue
    func addNotes(issue: Issue, notes: String) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            
            if let existingNotes = updatedIssue.notes {
                updatedIssue.notes = existingNotes + "\n\n" + notes
            } else {
                updatedIssue.notes = notes
            }
            
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Notes added to maintenance request '\(issue.title)'",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Complete an issue with actual costs and completion date
    func completeIssue(issue: Issue, actualCost: Double?, completionDate: Date = Date()) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            updatedIssue.actualCost = actualCost
            updatedIssue.completionDate = completionDate
            updatedIssue.status = .resolved
            issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Maintenance request '\(issue.title)' completed on \(formattedDate(completionDate))" + (actualCost != nil ? " with actual cost of $\(String(format: "%.2f", actualCost!))" : ""),
                relatedItemId: issue.id
            ))
            
            // If this is a recurring issue, create the next occurrence
            if updatedIssue.isRecurring, let nextDueDate = updatedIssue.nextDueDate, !updatedIssue.skipNextOccurrence {
                createNextRecurringIssue(from: updatedIssue, nextDueDate: nextDueDate)
            }
        }
    }
    
    // Create next occurrence of a recurring issue
    private func createNextRecurringIssue(from issue: Issue, nextDueDate: Date) {
        let nextIssue = Issue(
            title: issue.title,
            description: issue.description,
            createdDate: nextDueDate,
            status: .open,
            createdBy: issue.createdBy,
            priority: issue.priority,
            assignedTo: issue.assignedTo,
            imageURLs: [],
            isRecurring: true,
            recurringFrequency: issue.recurringFrequency,
            nextDueDate: calculateNextDueDate(from: nextDueDate, frequency: issue.recurringFrequency),
            contractorId: issue.contractorId,
            estimatedCost: issue.estimatedCost,
            skipNextOccurrence: false,
            propertyId: issue.propertyId
        )
        
        issues.append(nextIssue)
        
        // Add to history
        historyService.addHistoryItem(item: HistoryItem(
            activityType: .issue,
            description: "Next occurrence of recurring maintenance request '\(issue.title)' scheduled for \(formattedDate(nextDueDate))",
            relatedItemId: nextIssue.id
        ))
    }
    
    // Calculate next due date based on frequency (reusing logic from PaymentService)
    private func calculateNextDueDate(from date: Date, frequency: PaymentFrequency) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch frequency {
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .quarterly:
            dateComponents.month = 3
        case .annually:
            dateComponents.year = 1
        case .oneTime:
            return nil
        }
        
        return calendar.date(byAdding: dateComponents, to: date)
    }
    
    // Format date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Mock service for managing contractors
class ContractorService: ObservableObject {
    @Published var contractors: [Contractor] = []
    @Published var availableContractors: [Contractor] = []
    @Published var bookedContractors: [UUID: [DateInterval]] = [:]
    let historyService = HistoryService()
    
    init() {
        // Load sample data
        loadSampleContractors()
    }
    
    func loadSampleContractors() {
        contractors = [
            Contractor(
                name: "John Smith",
                company: "Smith Plumbing Services",
                specialties: [.plumbing, .general],
                email: "john@smithplumbing.com",
                phone: "555-123-4567",
                hourlyRate: 75.00,
                isPreferred: true,
                rating: 5
            ),
            Contractor(
                name: "Lisa Johnson",
                company: "Johnson Electrical",
                specialties: [.electrical],
                email: "lisa@johnsonelectric.com",
                phone: "555-987-6543",
                hourlyRate: 85.00,
                isPreferred: true,
                rating: 5
            ),
            Contractor(
                name: "Carlos Rodriguez",
                company: "Rodriguez HVAC",
                specialties: [.hvac],
                email: "carlos@rodriguezhvac.com",
                phone: "555-456-7890",
                hourlyRate: 80.00,
                isPreferred: false,
                rating: 4
            ),
            Contractor(
                name: "Sarah Williams",
                company: "Williams Property Maintenance",
                specialties: [.general, .carpentry, .painting],
                email: "sarah@williamspm.com",
                phone: "555-789-0123",
                hourlyRate: 65.00,
                isPreferred: false,
                rating: 4
            ),
            Contractor(
                name: "Michael Lee",
                company: "Lee Landscaping",
                specialties: [.landscaping],
                email: "michael@leelandscaping.com",
                phone: "555-234-5678",
                hourlyRate: 60.00,
                isPreferred: false,
                rating: 3
            )
        ]
    }
    
    // Find contractors based on specialty
    func findContractors(specialty: ContractorSpecialty? = nil, preferredOnly: Bool = false) -> [Contractor] {
        var filtered = contractors
        
        if let specialty = specialty {
            filtered = filtered.filter { $0.specialties.contains(specialty) }
        }
        
        if preferredOnly {
            filtered = filtered.filter { $0.isPreferred }
        }
        
        return filtered.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
    }
    
    // Assign a contractor to an issue
    func assignContractor(contractor: Contractor, to issue: Issue, issueService: IssueService) {
        if let index = issueService.issues.firstIndex(where: { $0.id == issue.id }) {
            var updatedIssue = issue
            updatedIssue.contractorId = contractor.id
            issueService.issues[index] = updatedIssue
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .issue,
                description: "Contractor '\(contractor.name)' from '\(contractor.company)' assigned to maintenance request '\(issue.title)'",
                relatedItemId: issue.id
            ))
        }
    }
    
    // Get contractor details by ID
    func getContractor(by id: UUID) -> Contractor? {
        return contractors.first { $0.id == id }
    }
}

// Mock service for handling video uploads
class VideoService: ObservableObject {
    @Published var videos: [Video] = []
    @Published var uploadProgress: Float = 0
    @Published var isUploading: Bool = false
    
    init() {
        // Load sample data
        loadSampleVideos()
    }
    
    func loadSampleVideos() {
        videos = [
            Video(
                title: "Site inspection - January",
                description: "Monthly site inspection video for January",
                uploadDate: Date().addingTimeInterval(-86400 * 10), // 10 days ago
                duration: 123,
                uploadStatus: .completed
            ),
            Video(
                title: "Equipment testing",
                description: "Testing new equipment installation",
                uploadDate: Date().addingTimeInterval(-86400 * 20), // 20 days ago
                duration: 305,
                uploadStatus: .completed
            )
        ]
    }
    
    // In a real app, this would upload video data to a server
    func uploadVideo(title: String, description: String, videoURL: URL, completion: @escaping (Bool) -> Void) {
        // Simulate network request
        isUploading = true
        uploadProgress = 0
        
        // Create a new video object
        let newVideo = Video(
            title: title,
            description: description,
            url: videoURL,
            uploadStatus: .uploading
        )
        
        videos.append(newVideo)
        
        // Simulate upload progress
        var progress: Float = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            progress += 0.1
            self.uploadProgress = min(progress, 1.0)
            
            if progress >= 1.0 {
                timer.invalidate()
                self.isUploading = false
                
                // Update the video status to completed
                if let index = self.videos.firstIndex(where: { $0.id == newVideo.id }) {
                    let updatedVideo = Video(
                        id: newVideo.id,
                        title: newVideo.title,
                        description: newVideo.description,
                        uploadDate: newVideo.uploadDate,
                        duration: newVideo.duration,
                        url: newVideo.url,
                        uploadStatus: .completed
                    )
                    self.videos[index] = updatedVideo
                }
                
                completion(true)
            }
        }
    }
}

// Mock service for handling document management
class DocumentService: ObservableObject {
    @Published var documents: [Document] = []
    @Published var uploadProgress: Float = 0
    @Published var isUploading: Bool = false
    private let historyService = HistoryService()
    
    init() {
        // Load sample data
        loadSampleDocuments()
    }
    
    func loadSampleDocuments() {
        documents = [
            Document(
                title: "Apartment 3B Lease",
                description: "Annual lease agreement for Apartment 3B",
                documentType: .lease,
                uploadDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                fileURL: URL(string: "https://example.com/documents/lease_3b.pdf"),
                signatureStatus: .completed,
                signedDate: Date().addingTimeInterval(-86400 * 28), // 28 days ago
                signedBy: "tenant123",
                relatedEntityId: "property_3b"
            ),
            Document(
                title: "Unit 5C Move-in Checklist",
                description: "Detailed condition report for Unit 5C",
                documentType: .moveInChecklist,
                uploadDate: Date().addingTimeInterval(-86400 * 15), // 15 days ago
                fileURL: URL(string: "https://example.com/documents/checklist_5c.pdf"),
                signatureStatus: .pending,
                relatedEntityId: "property_5c"
            ),
            Document(
                title: "Lease Renewal - Smith Family",
                description: "Annual lease renewal for Smith family residence",
                documentType: .renewalAgreement,
                uploadDate: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                fileURL: URL(string: "https://example.com/documents/renewal_smith.pdf"),
                signatureStatus: .pending,
                relatedEntityId: "property_smith"
            )
        ]
    }
    
    // In a real app, this would upload document data to a server
    func uploadDocument(title: String, description: String, documentType: DocumentType, fileURL: URL, signatureRequired: Bool = false, relatedEntityId: String? = nil, completion: @escaping (Bool) -> Void) {
        // Simulate network request
        isUploading = true
        uploadProgress = 0
        
        // Create a new document object
        let newDocument = Document(
            title: title,
            description: description,
            documentType: documentType,
            fileURL: fileURL,
            signatureStatus: signatureRequired ? .pending : .notRequired,
            relatedEntityId: relatedEntityId
        )
        
        documents.append(newDocument)
        
        // Simulate upload progress
        var progress: Float = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            progress += 0.1
            self.uploadProgress = min(progress, 1.0)
            
            if progress >= 1.0 {
                timer.invalidate()
                self.isUploading = false
                
                // Add to history
                self.historyService.addHistoryItem(item: HistoryItem(
                    activityType: .document,
                    description: "Uploaded document: '\(title)'",
                    relatedItemId: newDocument.id
                ))
                
                completion(true)
            }
        }
    }
    
    // Process document signature
    func signDocument(document: Document, signedBy: String, completion: @escaping (Bool) -> Void) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            var signedDocument = document
            signedDocument.signatureStatus = .completed
            signedDocument.signedDate = Date()
            signedDocument.signedBy = signedBy
            
            documents[index] = signedDocument
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .document,
                description: "Document '\(document.title)' signed by \(signedBy)",
                relatedItemId: document.id
            ))
            
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // Reject document signature
    func rejectDocument(document: Document, rejectedBy: String, reason: String, completion: @escaping (Bool) -> Void) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            var rejectedDocument = document
            rejectedDocument.signatureStatus = .rejected
            
            documents[index] = rejectedDocument
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .document,
                description: "Document '\(document.title)' rejected by \(rejectedBy). Reason: \(reason)",
                relatedItemId: document.id
            ))
            
            completion(true)
        } else {
            completion(false)
        }
    }
}

// Mock service for handling history
class HistoryService: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    init() {
        // Load sample data
        loadSampleHistory()
    }
    
    func loadSampleHistory() {
        historyItems = [
            HistoryItem(
                activityType: .payment,
                description: "Paid $75.00 for Monthly subscription",
                date: Date().addingTimeInterval(-86400 * 3) // 3 days ago
            ),
            HistoryItem(
                activityType: .issue,
                description: "Created issue: 'Login problem on mobile'",
                date: Date().addingTimeInterval(-86400 * 7) // 7 days ago
            ),
            HistoryItem(
                activityType: .videoUpload,
                description: "Uploaded video: 'Project update - March'",
                date: Date().addingTimeInterval(-86400 * 14) // 14 days ago
            ),
            HistoryItem(
                activityType: .issue,
                description: "Maintenance request 'Leaking kitchen faucet' assigned to maintenance1",
                date: Date().addingTimeInterval(-86400 * 1) // 1 day ago
            ),
            HistoryItem(
                activityType: .issue,
                description: "Created recurring maintenance request: 'Monthly pest control'",
                date: Date().addingTimeInterval(-86400 * 10) // 10 days ago
            ),
            HistoryItem(
                activityType: .document,
                description: "Uploaded document: 'Apartment 3B Lease'",
                date: Date().addingTimeInterval(-86400 * 30) // 30 days ago
            ),
            HistoryItem(
                activityType: .document,
                description: "Document 'Apartment 3B Lease' signed by tenant123",
                date: Date().addingTimeInterval(-86400 * 28) // 28 days ago
            ),
            HistoryItem(
                activityType: .message,
                description: "New message received from landlord123",
                date: Date().addingTimeInterval(-86400 * 2) // 2 days ago
            )
        ]
    }
    
    // In a real app, this would make an API call to the backend
    func addHistoryItem(item: HistoryItem) {
        historyItems.append(item)
        historyItems.sort { $0.date > $1.date } // Newest first
        
        // In a real app, this would be sent to a backend API
    }
}

// Mock service for handling messages
class MessageService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var pendingMessages: [Message] = [] // Messages drafted offline
    @Published var isOfflineMode: Bool = false
    
    private let historyService = HistoryService()
    private let persistence = PersistenceManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        // Load sample data
        loadSampleMessages()
        
        // Check if we're offline
        checkConnectivity()
    }
    
    // Check connectivity status
    func checkConnectivity() {
        isOfflineMode = persistence.isOffline
        
        // If we were offline but now we're online, sync pending messages
        if !isOfflineMode && !pendingMessages.isEmpty {
            syncPendingMessages()
        }
    }
    
    func loadSampleMessages() {
        let calendar = Calendar.current
        
        messages = [
            Message(
                sender: "landlord123",
                recipient: "tenant123",
                content: "Hello! Just a reminder that I'll be stopping by tomorrow for the annual apartment inspection. Let me know if you have any questions.",
                timestamp: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                isRead: true
            ),
            Message(
                sender: "tenant123",
                recipient: "landlord123",
                content: "Thanks for letting me know. What time should I expect you?",
                timestamp: calendar.date(byAdding: .hour, value: -42, to: Date()) ?? Date(),
                isRead: true
            ),
            Message(
                sender: "landlord123",
                recipient: "tenant123",
                content: "I'll be there around 2 PM if that works for you.",
                timestamp: calendar.date(byAdding: .hour, value: -41, to: Date()) ?? Date(),
                isRead: false
            ),
            Message(
                sender: "landlord123",
                recipient: "tenant456",
                content: "Hi there! I've received your maintenance request about the heating system. A technician will come by on Friday.",
                timestamp: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                isRead: false
            )
        ]
        
        // Cache messages for offline access
        persistence.cacheMessages(messages)
    }
    
    // Send a new message and add to history
    func sendMessage(sender: String, recipient: String, content: String, attachments: [URL]? = nil) {
        let newMessage = Message(
            sender: sender,
            recipient: recipient,
            content: content,
            attachmentURLs: attachments
        )
        
        // Check if we're offline
        checkConnectivity()
        
        if isOfflineMode {
            // Store message for syncing later
            pendingMessages.append(newMessage)
            
            // Add to local cache
            persistence.cacheMessages([newMessage])
            
            // Also add to displayed messages so they appear in the UI
            messages.append(newMessage)
        } else {
            // Send message normally (would go to server in real app)
            messages.append(newMessage)
            
            // Schedule notification for recipient
            notificationManager.scheduleNewMessageNotification(from: sender, content: content)
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .message,
                description: "Message sent to \(recipient)",
                relatedItemId: newMessage.id
            ))
        }
    }
    
    // Sync pending messages when online
    func syncPendingMessages() {
        guard !pendingMessages.isEmpty else { return }
        
        let messagesToSync = pendingMessages
        pendingMessages = []
        
        for message in messagesToSync {
            // In a real app, would send to server here
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .message,
                description: "Message sent to \(message.recipient) (synced)",
                relatedItemId: message.id
            ))
        }
        
        // Notify user of successful sync
        notificationManager.scheduleSyncCompleteNotification(itemsUpdated: messagesToSync.count)
    }
    
    // Mark a message as read
    func markAsRead(message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            var updatedMessage = message
            updatedMessage.isRead = true
            messages[index] = updatedMessage
            
            // Update cache
            persistence.cacheMessages([updatedMessage])
        }
    }
    
    // Get all messages for the current user (either as sender or recipient)
    func getMessagesForUser(userId: String) -> [Message] {
        return messages.filter { $0.sender == userId || $0.recipient == userId }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // Get conversation between two users
    func getConversation(between user1: String, and user2: String) -> [Message] {
        return messages.filter { 
            ($0.sender == user1 && $0.recipient == user2) || 
            ($0.sender == user2 && $0.recipient == user1) 
        }.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    // Get all unique conversations for a user
    func getConversationsForUser(userId: String) -> [(String, Message)] {
        let userMessages = getMessagesForUser(userId: userId)
        var conversationPartners: [String: Message] = [:]
        
        for message in userMessages {
            let partner = message.sender == userId ? message.recipient : message.sender
            
            // Only add if this is a newer message than we already have
            if let existingMessage = conversationPartners[partner] {
                if message.timestamp > existingMessage.timestamp {
                    conversationPartners[partner] = message
                }
            } else {
                conversationPartners[partner] = message
            }
        }
        
        // Convert to array of tuples (partner, last message)
        return conversationPartners.map { ($0.key, $0.value) }
            .sorted { $0.1.timestamp > $1.1.timestamp }
    }
    
    // Draft a message for offline sending
    func draftMessage(sender: String, recipient: String, content: String, attachments: [URL]? = nil) {
        let draftMessage = Message(
            sender: sender,
            recipient: recipient,
            content: content,
            attachmentURLs: attachments
        )
        
        pendingMessages.append(draftMessage)
    }
}

// Mock service for handling properties
class PropertyService: ObservableObject {
    @Published var properties: [Property] = []
    private let historyService = HistoryService()
    
    init() {
        // Load sample data
        loadSampleProperties()
    }
    
    func loadSampleProperties() {
        properties = [
            Property(
                name: "Lakeside Apartment",
                address: "123 Lake View Dr, Seattle, WA 98101",
                description: "Modern 2-bedroom apartment with lake view",
                latitude: 47.6062,
                longitude: -122.3321,
                createdBy: "admin",
                tenantEmail: "tenant@example.com"
            ),
            Property(
                name: "Downtown Condo",
                address: "456 Main St, Seattle, WA 98104",
                description: "Luxury 1-bedroom condo in downtown",
                latitude: 47.6097,
                longitude: -122.3331,
                createdBy: "admin",
                tenantPhone: "555-123-4567"
            ),
            Property(
                name: "Green Hills House",
                address: "789 Forest Ave, Bellevue, WA 98004",
                description: "Spacious 3-bedroom family house",
                latitude: 47.6101,
                longitude: -122.2015,
                createdBy: "admin"
            )
        ]
    }
    
    // Add a new property
    func addProperty(name: String, address: String, description: String, latitude: Double, longitude: Double, createdBy: String, tenantEmail: String? = nil, tenantPhone: String? = nil) {
        let newProperty = Property(
            name: name,
            address: address,
            description: description,
            latitude: latitude,
            longitude: longitude,
            createdBy: createdBy,
            tenantEmail: tenantEmail,
            tenantPhone: tenantPhone
        )
        
        properties.append(newProperty)
        
        // Add to history
        historyService.addHistoryItem(item: HistoryItem(
            activityType: .property,
            description: "Added new property: '\(name)' at \(address)",
            relatedItemId: newProperty.id
        ))
    }
    
    // Update an existing property
    func updateProperty(property: Property, name: String? = nil, address: String? = nil, description: String? = nil, tenantEmail: String? = nil, tenantPhone: String? = nil) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            var updatedProperty = property
            
            if let name = name {
                updatedProperty = Property(
                    id: property.id,
                    name: name,
                    address: address ?? property.address,
                    description: description ?? property.description,
                    latitude: property.latitude,
                    longitude: property.longitude,
                    createdBy: property.createdBy,
                    tenantEmail: tenantEmail ?? property.tenantEmail,
                    tenantPhone: tenantPhone ?? property.tenantPhone
                )
            }
            
            properties[index] = updatedProperty
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .property,
                description: "Updated property: '\(property.name)'",
                relatedItemId: property.id
            ))
        }
    }
    
    // Invite a tenant for a property
    func inviteTenant(property: Property, email: String? = nil, phone: String? = nil, completion: @escaping (Bool) -> Void) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            var updatedProperty = property
            updatedProperty.tenantEmail = email ?? property.tenantEmail
            updatedProperty.tenantPhone = phone ?? property.tenantPhone
            properties[index] = updatedProperty
            
            // In a real app, this would send an email or SMS
            // For now we just simulate it
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .property,
                description: "Invited tenant to property '\(property.name)' via \(email != nil ? "email" : "phone")",
                relatedItemId: property.id
            ))
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    // Delete a property
    func deleteProperty(property: Property) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties.remove(at: index)
            
            // Add to history
            historyService.addHistoryItem(item: HistoryItem(
                activityType: .property,
                description: "Removed property: '\(property.name)'",
                relatedItemId: property.id
            ))
        }
    }
    
    // Get properties for a specific user
    func getPropertiesForUser(userId: String, isAdmin: Bool) -> [Property] {
        if isAdmin {
            // Admins see all properties they've created
            return properties.filter { $0.createdBy == userId }
        } else {
            // Regular users only see properties where they're the tenant
            // In a real app, this would be based on tenant ID rather than email/phone
            return []
        }
    }
}