import SwiftUI

struct IssuesView: View {
    @ObservedObject var issueService = IssueService()
    @State private var showingCreateIssue = false
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        NavigationView {
            List {
                ForEach(issueService.issues) { issue in
                    IssueRowView(issue: issue)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Issue: \(issue.title), Status: \(issue.status.rawValue)")
                        .accessibilityHint("Double tap to view details")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Issues")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingCreateIssue = true
                    }) {
                        Label("Create Issue", systemImage: "square.and.pencil")
                    }
                    .accessibilityLabel("Create new issue")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(issue.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(issue.description)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
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
                
                Spacer()
                
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
    @State private var showingConfirmation = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
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
                            .submitLabel(.done)
                    }
                }
            }
            .navigationTitle("Create Issue")
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
            .alert("Submit Issue", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Submit") {
                    issueService.createIssue(title: title, description: description)
                    isPresented = false
                }
            } message: {
                Text("Are you sure you want to submit this issue?")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .title
                }
            }
        }
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