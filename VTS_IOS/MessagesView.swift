import SwiftUI

public struct MessagesView: View {
    @StateObject private var messageService = MessageService()
    @State private var selectedConversation: String? = nil
    @State private var composedMessage: String = ""
    @State private var searchText: String = ""
    @State private var isShowingPersonPicker = false
    @State private var recipient: String = ""
    @State private var showingOfflineBanner = false
    @StateObject private var localization = LocalizationManager.shared
    
    // Mock current user ID - in a real app this would come from authentication
    let currentUserId = "tenant123"
    
    var filteredConversations: [(String, Message)] {
        if searchText.isEmpty {
            return messageService.getConversationsForUser(userId: currentUserId)
        } else {
            return messageService.getConversationsForUser(userId: currentUserId)
                .filter { $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Offline mode banner
                if messageService.isOfflineMode {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.white)
                        Text(localization.localized("offline"))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            // Attempt to sync
                            PersistenceManager.shared.syncWhenOnline { success in
                                if success {
                                    messageService.checkConnectivity()
                                }
                            }
                        }) {
                            Text(localization.localized("sync"))
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .transition(.move(edge: .top))
                }
                
                if selectedConversation == nil {
                    // Conversations list view
                    VStack {
                        SearchBar(text: $searchText, placeholder: "Search conversations")
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        List {
                            ForEach(filteredConversations, id: \.0) { partner, lastMessage in
                                ConversationRow(
                                    partnerId: partner,
                                    lastMessage: lastMessage,
                                    currentUserId: currentUserId
                                )
                                .onTapGesture {
                                    selectedConversation = partner
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        Button(action: {
                            isShowingPersonPicker = true
                        }) {
                            Label(localization.localized("new_message"), systemImage: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                } else {
                    // Conversation detail view
                    ConversationView(
                        partnerId: selectedConversation!,
                        currentUserId: currentUserId,
                        messageService: messageService,
                        composedMessage: $composedMessage,
                        onBack: { selectedConversation = nil }
                    )
                }
            }
            .navigationTitle(selectedConversation == nil ? "Messages" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedConversation == nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingPersonPicker = true
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingPersonPicker) {
            PersonPickerView(
                isPresented: $isShowingPersonPicker,
                onPersonSelected: { person in
                    selectedConversation = person
                    recipient = person
                }
            )
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ConversationRow: View {
    let partnerId: String
    let lastMessage: Message
    let currentUserId: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(partnerId)
                        .font(.headline)
                    Spacer()
                    Text(formatDate(lastMessage.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if lastMessage.sender == currentUserId {
                        Text("You: ")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if !lastMessage.isRead && lastMessage.recipient == currentUserId {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}

struct ConversationView: View {
    let partnerId: String
    let currentUserId: String
    var messageService: MessageService
    @Binding var composedMessage: String
    var onBack: () -> Void
    @ObservedObject private var localization = LocalizationManager.shared
    
    var conversation: [Message] {
        return messageService.getConversation(between: currentUserId, and: partnerId)
    }
    
    var body: some View {
        VStack {
            // Navigation bar for small screens
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(localization.localized("back"))
                    }
                }
                
                Spacer()
                
                Text(partnerId)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        ForEach(conversation) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.sender == currentUserId,
                                isPending: messageService.pendingMessages.contains(where: { $0.id == message.id })
                            )
                            .id(message.id)
                            .onAppear {
                                if !message.isRead && message.recipient == currentUserId {
                                    messageService.markAsRead(message: message)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    if let lastMessageId = conversation.last?.id {
                        scrollView.scrollTo(lastMessageId)
                    }
                }
            }
            
            // Message composer
            HStack {
                TextField(localization.localized("message_placeholder"), text: $composedMessage)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    if !composedMessage.isEmpty {
                        if messageService.isOfflineMode {
                            // Show a subtle indicator that message will be sent when online
                            messageService.sendMessage(
                                sender: currentUserId,
                                recipient: partnerId,
                                content: composedMessage
                            )
                        } else {
                            messageService.sendMessage(
                                sender: currentUserId,
                                recipient: partnerId,
                                content: composedMessage
                            )
                        }
                        composedMessage = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageService.isOfflineMode ? .orange : .blue)
                        .padding(10)
                }
            }
            .padding()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    var isPending: Bool
    @ObservedObject private var localization = LocalizationManager.shared
    
    init(message: Message, isCurrentUser: Bool, isPending: Bool = false) {
        self.message = message
        self.isCurrentUser = isCurrentUser
        self.isPending = isPending
    }
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 3) {
                Text(message.content)
                    .padding(10)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .background(isCurrentUser ? (isPending ? Color.orange : Color.blue) : Color(.systemGray5))
                    .cornerRadius(16)
                
                HStack {
                    Text(formatTime(message.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if isPending {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else if isCurrentUser {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = localization.currentLocale
        return formatter.string(from: date)
    }
}

// Simple mock person picker - in a real app this would be more sophisticated
struct PersonPickerView: View {
    @Binding var isPresented: Bool
    var onPersonSelected: (String) -> Void
    
    // In a real app, this would be loaded from an API
    let samplePeople = ["landlord123", "maintenance1", "contractor2", "manager456"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(samplePeople, id: \.self) { person in
                    Button(action: {
                        onPersonSelected(person)
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text(person)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}