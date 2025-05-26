import SwiftUI

struct IssuesView: View {
    @ObservedObject var issueService = IssueService()
    @State private var showingCreateIssue = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(issueService.issues) { issue in
                    IssueRowView(issue: issue)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Issues", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingCreateIssue = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingCreateIssue) {
                CreateIssueView(issueService: issueService, isPresented: $showingCreateIssue)
            }
        }
    }
}

struct IssueRowView: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(issue.title)
                .font(.headline)
            
            Text(issue.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                Text(formattedDate(issue.createdDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(issue.status.rawValue)
                    .font(.caption)
                    .bold()
                    .padding(5)
                    .background(statusColor(for: issue.status))
                    .cornerRadius(5)
                    .foregroundColor(.white)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 5)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func statusColor(for status: IssueStatus) -> Color {
        switch status {
        case .open:
            return .orange
        case .inProgress:
            return .blue
        case .resolved:
            return .green
        case .closed:
            return .gray
        }
    }
}

struct CreateIssueView: View {
    @ObservedObject var issueService: IssueService
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Issue Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationBarTitle("Create Issue", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Submit") {
                    if !title.isEmpty {
                        issueService.createIssue(title: title, description: description)
                        isPresented = false
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var previews: some View {
        IssuesView()
    }
}