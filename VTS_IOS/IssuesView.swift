import SwiftUI
import UIKit

struct IssuesView: View {
    @ObservedObject var issueService = IssueService()
    @State private var showingCreateIssue = false
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        NavigationView {
            List {
                ForEach(issueService.issues) { issue in
                    NavigationLink(destination: IssueDetailView(issueService: issueService, issue: issue)) {
                        IssueRowView(issue: issue)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Issue: \(issue.title), Status: \(issue.status.rawValue)")
                            .accessibilityHint("Double tap to view details")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Maintenance Requests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingCreateIssue = true
                    }) {
                        Label("Create Request", systemImage: "square.and.pencil")
                    }
                    .accessibilityLabel("Create new maintenance request")
                }
            }
            .sheet(isPresented: $showingCreateIssue) {
                CreateIssueView(issueService: issueService, isPresented: $showingCreateIssue)
            }
        }
    }
}

struct IssueRowView: View {
    let issue: Issue
    @StateObject private var contractorService = ContractorService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(issue.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Display priority tag
                Text(issue.priority.rawValue)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(priorityColor(for: issue.priority))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text(issue.description)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            // Show first image thumbnail if available
            if let firstImageURL = issue.imageURLs.first {
                HStack {
                    Image(systemName: "photo")
                        .foregroundColor(.blue)
                    Text("\(issue.imageURLs.count) image\(issue.imageURLs.count > 1 ? "s" : "")")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 2)
            }
            
            // Show cost information if available
            if let estimatedCost = issue.estimatedCost {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.blue)
                        .font(.footnote)
                    
                    Text("Est. cost: $\(String(format: "%.2f", estimatedCost))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    if let actualCost = issue.actualCost {
                        Text("Actual: $\(String(format: "%.2f", actualCost))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 2)
            }
            
            HStack {
                // Show date and completion status
                if let completionDate = issue.completionDate {
                    Label {
                        Text("Completed: \(formattedDate(completionDate))")
                            .font(.footnote)
                            .foregroundColor(.green)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                } else {
                    Label {
                        Text(formattedDate(issue.createdDate))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .accessibilityLabel("Created on \(formattedDate(issue.createdDate))")
                }
                
                Spacer()
                
                // Show recurring indicator if applicable
                if issue.isRecurring {
                    Label {
                        Text(issue.recurringFrequency.rawValue)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    .padding(.trailing, 8)
                }
                
                HStack(spacing: 4) {
                    statusIcon(for: issue.status)
                        .font(.footnote)
                        .foregroundColor(.white)
                    
                    Text(issue.status.rawValue)
                        .font(.footnote)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(statusColor(for: issue.status))
                        .cornerRadius(6)
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Status: \(issue.status.rawValue)")
            }
            .padding(.top, 5)
            
            // Show assigned to information if available
            if let assignedTo = issue.assignedTo {
                HStack {
                    Label {
                        Text("Staff: \(assignedTo)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .padding(.top, 2)
            }
            
            // Show contractor information if available
            if let contractorId = issue.contractorId, 
               let contractor = contractorService.getContractor(by: contractorId) {
                HStack {
                    Label {
                        Text("Contractor: \(contractor.name), \(contractor.company)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "wrench.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                .padding(.top, 2)
            }
            
            // Show expected response time based on priority
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(issue.priority == .urgent ? .red : .secondary)
                    .font(.caption)
                
                Text("Response: \(issue.priority.estimatedResponseTime)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func statusColor(for status: IssueStatus) -> Color {
        switch status {
        case .open:
            return Color(.systemOrange)
        case .inProgress:
            return Color(.systemBlue)
        case .resolved:
            return Color(.systemGreen)
        case .closed:
            return Color(.systemGray)
        }
    }
    
    private func priorityColor(for priority: IssuePriority) -> Color {
        switch priority {
        case .low:
            return Color(.systemGreen)
        case .medium:
            return Color(.systemBlue)
        case .high:
            return Color(.systemOrange)
        case .urgent:
            return Color(.systemRed)
        }
    }
    
    private func statusIcon(for status: IssueStatus) -> some View {
        let iconName: String
        
        switch status {
        case .open:
            iconName = "exclamationmark.circle.fill"
        case .inProgress:
            iconName = "person.fill.checkmark"
        case .resolved:
            iconName = "checkmark.circle.fill"
        case .closed:
            iconName = "xmark.circle.fill"
        }
        
        return Image(systemName: iconName)
    }
}

struct CreateIssueView: View {
    @ObservedObject var issueService: IssueService
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedPriority: IssuePriority = .medium
    @State private var isRecurring: Bool = false
    @State private var selectedFrequency: PaymentFrequency = .monthly
    @State private var showingPhotoPickerSheet = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingConfirmation = false
    @State private var estimatedCost: String = ""
    @State private var selectedPropertyId: UUID? = nil
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description, cost
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Issue Details")) {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .font(.body)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .description
                        }
                        .accessibilityLabel("Issue title")
                        .accessibilityHint("Enter a concise title for your issue")
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                        
                        TextEditor(text: $description)
                            .focused($focusedField, equals: .description)
                            .frame(minHeight: 100)
                            .fontWeight(.regular)
                            .accessibilityLabel("Issue description")
                            .accessibilityHint("Enter details about your issue")
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .cost
                            }
                    }
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(IssuePriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("Expected response: \(selectedPriority.estimatedResponseTime)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Cost Estimate")) {
                    TextField("Estimated Cost", text: $estimatedCost)
                        .focused($focusedField, equals: .cost)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("Estimated cost for maintenance")
                        .submitLabel(.done)
                }
                
                Section(header: Text("Photos")) {
                    Button(action: {
                        showingPhotoPickerSheet = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(.blue)
                            Text("Add Photos")
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<selectedImages.count, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .overlay(
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4),
                                            alignment: .topTrailing
                                        )
                                        .padding(2)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Recurring Maintenance")) {
                    Toggle("Set as Recurring", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Frequency", selection: $selectedFrequency) {
                            ForEach([PaymentFrequency.weekly, .monthly, .quarterly, .annually], id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Maintenance Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityLabel("Cancel creating issue")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        if title.isEmpty {
                            focusedField = .title
                        } else {
                            showingConfirmation = true
                        }
                    }
                    .font(.body.bold())
                    .foregroundColor(title.isEmpty ? .gray : .accentColor)
                    .disabled(title.isEmpty)
                    .accessibilityLabel("Submit issue")
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: {
                        focusedField = nil
                    }) {
                        Text("Done")
                    }
                }
            }
            .alert("Submit Maintenance Request", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Submit") {
                    // Create mock image URLs for the demo
                    let mockImageURLs = selectedImages.indices.map { _ in 
                        URL(string: "https://example.com/image\(UUID().uuidString).jpg")! 
                    }
                    
                    let estimatedCostValue = Double(estimatedCost.replacingOccurrences(of: ",", with: "."))
                    
                    issueService.createIssue(
                        title: title, 
                        description: description,
                        priority: selectedPriority,
                        imageURLs: mockImageURLs,
                        isRecurring: isRecurring,
                        recurringFrequency: isRecurring ? selectedFrequency : .oneTime,
                        estimatedCost: estimatedCostValue,
                        propertyId: selectedPropertyId
                    )
                    isPresented = false
                }
            } message: {
                Text("Are you sure you want to submit this maintenance request?")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .title
                }
            }
            .actionSheet(isPresented: $showingPhotoPickerSheet) {
                ActionSheet(
                    title: Text("Select Photo Source"),
                    message: Text("Choose a source for your photo"),
                    buttons: [
                        .default(Text("Camera")) {
                            // In a real app, this would open the camera
                            // For this demo, we'll just add a mock photo
                            selectedImages.append(UIImage(systemName: "photo")!)
                        },
                        .default(Text("Photo Library")) {
                            // In a real app, this would open the photo library
                            // For this demo, we'll just add a mock photo
                            selectedImages.append(UIImage(systemName: "photo")!)
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}
}

// Issue Detail View for viewing issue details and managing task assignments
struct IssueDetailView: View {
    @ObservedObject var issueService: IssueService
    @StateObject private var contractorService = ContractorService()
    let issue: Issue
    @State private var showingStatusSheet = false
    @State private var showingAssignSheet = false
    @State private var showingContractorSheet = false
    @State private var showingNoteSheet = false
    @State private var showingCostSheet = false
    @State private var showingSkipConfirmation = false
    @State private var assignToName: String = ""
    @State private var noteText: String = ""
    @State private var estimatedCostText: String = ""
    @State private var actualCostText: String = ""
    @State private var selectedContractor: Contractor? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and priority
                HStack {
                    Text(issue.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(issue.priority.rawValue)
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(priorityColor(for: issue.priority))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Status and date
                HStack {
                    Label {
                        Text(formattedDate(issue.createdDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingStatusSheet = true
                    }) {
                        HStack {
                            Text(issue.status.rawValue)
                                .font(.subheadline)
                                .bold()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor(for: issue.status))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Expected response time based on priority
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    
                    Text("Expected response: \(issue.priority.estimatedResponseTime)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(issue.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // Assignment section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Assignment")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAssignSheet = true
                        }) {
                            Text(issue.assignedTo == nil ? "Assign Staff" : "Reassign Staff")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            showingContractorSheet = true
                        }) {
                            Text(issue.contractorId == nil ? "Assign Contractor" : "Change Contractor")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    if let assignedTo = issue.assignedTo {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                            
                            Text("Assigned to staff: \(assignedTo)")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if let contractorId = issue.contractorId,
                       let contractor = contractorService.getContractor(by: contractorId) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "wrench.fill")
                                    .foregroundColor(.green)
                                
                                Text("Assigned contractor: \(contractor.name)")
                                    .font(.subheadline)
                            }
                            
                            Text("Company: \(contractor.company)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                            
                            HStack {
                                Text("Specialties:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(contractor.specialties, id: \.self) { specialty in
                                    Text(specialty.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.leading, 24)
                            
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(contractor.phone)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                                
                                Text(contractor.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 24)
                            
                            if let hourlyRate = contractor.hourlyRate {
                                Text("Rate: $\(String(format: "%.2f", hourlyRate))/hr")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                            }
                        }
                        .padding(.vertical, 4)
                    } else if issue.assignedTo == nil {
                        Text("Not yet assigned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(.horizontal)
                
                // Cost information section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Cost Information")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            if let estimatedCost = issue.estimatedCost {
                                estimatedCostText = String(format: "%.2f", estimatedCost)
                            }
                            if let actualCost = issue.actualCost {
                                actualCostText = String(format: "%.2f", actualCost)
                            }
                            showingCostSheet = true
                        }) {
                            Text("Update Costs")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let estimatedCost = issue.estimatedCost {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.blue)
                            
                            Text("Estimated cost: $\(String(format: "%.2f", estimatedCost))")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if let actualCost = issue.actualCost {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                            
                            Text("Actual cost: $\(String(format: "%.2f", actualCost))")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if let completionDate = issue.completionDate {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text("Completed on: \(formattedDate(completionDate))")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.horizontal)
                
                // Recurring information
                if issue.isRecurring {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recurring Maintenance")
                                .font(.headline)
                            
                            Spacer()
                            
                            if !issue.skipNextOccurrence && issue.status != .closed && issue.status != .resolved {
                                Button(action: {
                                    showingSkipConfirmation = true
                                }) {
                                    Text("Skip Next Occurrence")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.blue)
                            
                            Text("Repeats: \(issue.recurringFrequency.rawValue)")
                                .font(.subheadline)
                        }
                        
                        if let nextDueDate = issue.nextDueDate {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.blue)
                                
                                Text("Next occurrence: \(formattedDate(nextDueDate))")
                                    .font(.subheadline)
                            }
                        }
                        
                        if issue.skipNextOccurrence {
                            HStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundColor(.orange)
                                
                                Text("Next occurrence will be skipped")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Notes section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Notes")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingNoteSheet = true
                        }) {
                            Text("Add Note")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let notes = issue.notes {
                        Text(notes)
                            .font(.body)
                            .padding(10)
                            .frame(minHeight: 60)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    } else {
                        Text("No notes yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(.horizontal)
                
                // Images
                if !issue.imageURLs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photos")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(issue.imageURLs, id: \.self) { imageURL in
                                    VStack {
                                        // In a real app, this would load from the URL
                                        // For this demo, we'll use a system image
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 200, height: 150)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                        
                                        Text(imageURL.lastPathComponent)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Request Details", displayMode: .inline)
        .actionSheet(isPresented: $showingStatusSheet) {
            ActionSheet(
                title: Text("Update Status"),
                message: Text("Select a new status for this request"),
                buttons: IssueStatus.allCases.map { status in
                    .default(Text(status.rawValue)) {
                        issueService.updateIssueStatus(issue: issue, status: status)
                    }
                } + [.cancel()]
            )
        }
        .alert("Assign Request", isPresented: $showingAssignSheet) {
            TextField("Name or ID", text: $assignToName)
            
            Button("Cancel", role: .cancel) {
                assignToName = ""
            }
            
            Button("Assign") {
                if !assignToName.isEmpty {
                    issueService.assignIssue(issue: issue, to: assignToName)
                    assignToName = ""
                }
            }
        } message: {
            Text("Enter the name or ID of the staff member to assign this request to")
        }
        .alert("Add Note", isPresented: $showingNoteSheet) {
            TextField("Note", text: $noteText)
            
            Button("Cancel", role: .cancel) {
                noteText = ""
            }
            
            Button("Add") {
                if !noteText.isEmpty {
                    issueService.addNotes(issue: issue, notes: noteText)
                    noteText = ""
                }
            }
        } message: {
            Text("Add a note to this maintenance request")
        }
        .alert("Update Costs", isPresented: $showingCostSheet) {
            TextField("Estimated Cost", text: $estimatedCostText)
                .keyboardType(.decimalPad)
            
            TextField("Actual Cost", text: $actualCostText)
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel) {
                estimatedCostText = ""
                actualCostText = ""
            }
            
            Button("Update") {
                let estimatedCost = Double(estimatedCostText.replacingOccurrences(of: ",", with: "."))
                let actualCost = Double(actualCostText.replacingOccurrences(of: ",", with: "."))
                
                issueService.updateCosts(issue: issue, estimatedCost: estimatedCost, actualCost: actualCost)
                estimatedCostText = ""
                actualCostText = ""
            }
        } message: {
            Text("Update cost information for this maintenance request")
        }
        .alert("Skip Next Occurrence", isPresented: $showingSkipConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Skip", role: .destructive) {
                issueService.skipNextOccurrence(issue: issue)
            }
        } message: {
            Text("Are you sure you want to skip the next occurrence of this recurring maintenance task?")
        }
        .sheet(isPresented: $showingContractorSheet) {
            ContractorSelectionView(
                contractorService: contractorService,
                issueService: issueService,
                issue: issue,
                isPresented: $showingContractorSheet
            )
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func statusColor(for status: IssueStatus) -> Color {
        switch status {
        case .open:
            return Color(.systemOrange)
        case .inProgress:
            return Color(.systemBlue)
        case .resolved:
            return Color(.systemGreen)
        case .closed:
            return Color(.systemGray)
        }
    }
    
    private func priorityColor(for priority: IssuePriority) -> Color {
        switch priority {
        case .low:
            return Color(.systemGreen)
        case .medium:
            return Color(.systemBlue)
        case .high:
            return Color(.systemOrange)
        case .urgent:
            return Color(.systemRed)
        }
    }
}

// View for selecting contractors
struct ContractorSelectionView: View {
    @ObservedObject var contractorService: ContractorService
    @ObservedObject var issueService: IssueService
    let issue: Issue
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    @State private var showPreferredOnly: Bool = false
    @State private var selectedSpecialty: ContractorSpecialty? = nil
    
    var filteredContractors: [Contractor] {
        contractorService.findContractors(
            specialty: selectedSpecialty,
            preferredOnly: showPreferredOnly
        ).filter { contractor in
            if searchText.isEmpty {
                return true
            }
            return contractor.name.localizedCaseInsensitiveContains(searchText) ||
                   contractor.company.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and filter controls
                VStack {
                    TextField("Search contractors", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack {
                        Toggle("Preferred Only", isOn: $showPreferredOnly)
                        
                        Spacer()
                        
                        Picker("Specialty", selection: $selectedSpecialty) {
                            Text("All Specialties").tag(nil as ContractorSpecialty?)
                            ForEach(ContractorSpecialty.allCases, id: \.self) { specialty in
                                Text(specialty.rawValue).tag(Optional(specialty))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                // List of contractors
                List {
                    ForEach(filteredContractors) { contractor in
                        Button(action: {
                            issueService.assignContractor(issue: issue, contractorId: contractor.id)
                            isPresented = false
                        }) {
                            ContractorRow(contractor: contractor, isSelected: contractor.id == issue.contractorId)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Select Contractor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct ContractorRow: View {
    let contractor: Contractor
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contractor.name)
                        .font(.headline)
                    
                    if contractor.isPreferred {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    if let rating = contractor.rating {
                        HStack(spacing: 2) {
                            ForEach(0..<rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            ForEach(0..<(5-rating), id: \.self) { _ in
                                Image(systemName: "star")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                Text(contractor.company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(contractor.specialties, id: \.self) { specialty in
                        Text(specialty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    if let hourlyRate = contractor.hourlyRate {
                        Text("$\(String(format: "%.2f", hourlyRate))/hr")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(contractor.phone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isSelected {
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IssuesView()
                .previewDisplayName("Default")
            
            IssuesView()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Accessibility - XXXL")
            
            IssuesView()
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}