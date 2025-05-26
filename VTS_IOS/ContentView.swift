import SwiftUI

struct ContentView: View {
    @ObservedObject var authentication: UserAuthentication
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        TabView {
            PaymentsView()
                .tabItem {
                    Label("Payments", systemImage: "dollarsign.circle.fill")
                }
                .accessibilityLabel("Payments Tab")
            
            IssuesView()
                .tabItem {
                    Label("Maintenance", systemImage: "wrench.fill")
                }
                .accessibilityLabel("Maintenance Requests Tab")
            
            DocumentsView()
                .tabItem {
                    Label("Documents", systemImage: "doc.fill")
                }
                .accessibilityLabel("Documents Tab")
            
            VideoUploadView()
                .tabItem {
                    Label("Videos", systemImage: "video.fill")
                }
                .accessibilityLabel("Video Upload Tab")
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .accessibilityLabel("Activity History Tab")
            
            ProfileView(authentication: authentication)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .accessibilityLabel("User Profile Tab")
        }
        .accentColor(Color(.systemBlue))
    }
}

struct ProfileView: View {
    @ObservedObject var authentication: UserAuthentication
    @Environment(\.sizeCategory) var sizeCategory
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(.systemBlue))
                        .padding()
                        .accessibilityHidden(true) // Hidden because it's decorative
                    
                    Text("Welcome to VTS iOS App")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("You are logged in as \(authentication.currentUsername)")
                        .font(.body)
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.bottom, 8)
                    
                    // User information would go here in a real app
                    VStack(alignment: .leading, spacing: 12) {
                        ProfileInfoRow(icon: "envelope.fill", label: "Email", value: "user@example.com")
                        ProfileInfoRow(icon: "phone.fill", label: "Phone", value: "(555) 123-4567")
                        ProfileInfoRow(icon: "building.2.fill", label: "Company", value: "VTS Inc.")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemRed))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .accessibilityHint("Double tap to log out of your account")
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    withAnimation {
                        authentication.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(.systemBlue))
                .frame(width: 20)
                .accessibilityHidden(true)
            
            Text(label)
                .foregroundColor(Color(.secondaryLabel))
                .font(.callout)
                .frame(width: 70, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(Color(.label))
            
            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(authentication: UserAuthentication())
                .previewDisplayName("Default")
            
            ContentView(authentication: UserAuthentication())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ContentView(authentication: UserAuthentication())
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDisplayName("Large Text")
        }
    }
}