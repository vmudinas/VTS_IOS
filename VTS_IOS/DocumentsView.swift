import SwiftUI

struct DocumentsView: View {
    @ObservedObject var documentService = DocumentService()
    @State private var showingDocumentUploadForm = false
    @State private var showingDocumentPickerSheet = false
    @State private var selectedDocumentURL: URL? = nil
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            List {
                if documentService.isUploading {
                    Section {
                        // Upload progress view
                        VStack {
                            ProgressView("Uploading document...", value: Double(documentService.uploadProgress), total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                            
                            Text("\(Int(documentService.uploadProgress * 100))%")
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text(localization.localized("documents"))) {
                    ForEach(documentService.documents) { document in
                        NavigationLink(destination: DocumentDetailView(document: document)) {
                            DocumentRowView(document: document)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(localization.localized("documents"))
            .navigationBarItems(
                trailing: Button(action: {
                    showingDocumentUploadForm = true
                }) {
                    Image(systemName: "plus")
                        .accessibilityLabel("Upload document")
                }
            )
            .sheet(isPresented: $showingDocumentUploadForm) {
                DocumentUploadView(isPresented: $showingDocumentUploadForm)
            }
        }
    }
}

struct DocumentRowView: View {
    let document: Document
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.title)
                .font(.headline)
            
            Text(document.documentType.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: documentTypeIcon(document.documentType))
                    .foregroundColor(.blue)
                
                Text(formattedDate(document.uploadDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                signatureStatusView(document.signatureStatus)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
    
    private func documentTypeIcon(_ type: DocumentType) -> String {
        switch type {
        case .lease:
            return "doc.text.fill"
        case .moveInChecklist:
            return "checklist"
        case .renewalAgreement:
            return "arrow.clockwise.circle.fill"
        case .other:
            return "doc.fill"
        }
    }
    
    private func signatureStatusView(_ status: SignatureStatus) -> some View {
        Group {
            switch status {
            case .notRequired:
                Text("No signature needed")
                    .font(.caption)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            case .pending:
                Text("Signature needed")
                    .font(.caption)
                    .padding(4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(Color.orange)
                    .cornerRadius(4)
            case .completed:
                Text("Signed")
                    .font(.caption)
                    .padding(4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(Color.green)
                    .cornerRadius(4)
            case .rejected:
                Text("Rejected")
                    .font(.caption)
                    .padding(4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(Color.red)
                    .cornerRadius(4)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DocumentDetailView: View {
    let document: Document
    @ObservedObject var documentService = DocumentService()
    @State private var showingSignatureConfirmation = false
    @State private var showingRejectionConfirmation = false
    @State private var rejectionReason = ""
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Document header
                HStack {
                    Image(systemName: documentTypeIcon(document.documentType))
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(document.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(document.documentType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Document details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(document.description)
                        .padding(.bottom, 8)
                    
                    Text("Uploaded")
                        .font(.headline)
                    
                    Text(formattedDate(document.uploadDate))
                        .padding(.bottom, 8)
                    
                    if document.signatureStatus == .completed, let signedDate = document.signedDate, let signedBy = document.signedBy {
                        Text("Signed By")
                            .font(.headline)
                        
                        Text("\(signedBy) on \(formattedDate(signedDate))")
                    }
                }
                .padding()
                
                // Document preview (in a real app, this would show the actual document)
                VStack {
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Document Preview")
                        .font(.headline)
                    
                    Text("In a real app, the document would be displayed here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Signature buttons
                if document.signatureStatus == .pending {
                    VStack(spacing: 12) {
                        Button(action: {
                            showingSignatureConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "signature")
                                Text("Sign Document")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingRejectionConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Reject Document")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationBarTitle(localization.localized("document_details"), displayMode: .inline)
        .alert("Sign Document", isPresented: $showingSignatureConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign") {
                documentService.signDocument(document: document, signedBy: "user123") { success in
                    // In a real app, you would handle success/failure
                }
            }
        } message: {
            Text("Are you sure you want to sign this document?")
        }
        .alert("Reject Document", isPresented: $showingRejectionConfirmation) {
            TextField("Reason for rejection", text: $rejectionReason)
            Button("Cancel", role: .cancel) {}
            Button("Reject", role: .destructive) {
                if !rejectionReason.isEmpty {
                    documentService.rejectDocument(document: document, rejectedBy: "user123", reason: rejectionReason) { success in
                        // In a real app, you would handle success/failure
                        rejectionReason = ""
                    }
                }
            }
        } message: {
            Text("Please provide a reason for rejecting this document.")
        }
    }
    
    private func documentTypeIcon(_ type: DocumentType) -> String {
        switch type {
        case .lease:
            return "doc.text.fill"
        case .moveInChecklist:
            return "checklist"
        case .renewalAgreement:
            return "arrow.clockwise.circle.fill"
        case .other:
            return "doc.fill"
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DocumentUploadView: View {
    @ObservedObject var documentService = DocumentService()
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDocumentType: DocumentType = .lease
    @State private var signatureRequired = false
    @State private var showingConfirmation = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Document Details")) {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                    
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
                    }
                }
                
                Section(header: Text("Document Type")) {
                    Picker("Document Type", selection: $selectedDocumentType) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    Toggle("Requires Signature", isOn: $signatureRequired)
                }
                
                Section {
                    // Document preview placeholder
                    HStack {
                        Spacer()
                        Image(systemName: "doc.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 120)
                    
                    Button("Select Document") {
                        // In a real app, this would open a document picker
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle(localization.localized("upload_document"))
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Upload") {
                    if !title.isEmpty {
                        showingConfirmation = true
                    }
                }
                .disabled(title.isEmpty)
            )
            .alert("Upload Document", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Upload") {
                    // Create a mock URL for demonstration
                    let mockURL = URL(string: "https://example.com/documents/\(UUID().uuidString).pdf")!
                    
                    // Call the upload function
                    documentService.uploadDocument(
                        title: title,
                        description: description,
                        documentType: selectedDocumentType,
                        fileURL: mockURL,
                        signatureRequired: signatureRequired
                    ) { success in
                        if success {
                            isPresented = false
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to upload this document?")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .title
                }
            }
        }
    }
}

struct DocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsView()
    }
}