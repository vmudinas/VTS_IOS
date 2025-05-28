import SwiftUI
import Foundation
import Combine

// Import all required components
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject var authentication = UserAuthentication()
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        TabView {
            PaymentsView()
                .tabItem {
                    Label(localization.localized("payments"), systemImage: "dollarsign.circle.fill")
                }
                .accessibilityLabel("\(localization.localized("payments")) Tab")
            
            FinancialReportView()
                .tabItem {
                    Label(localization.localized("finances"), systemImage: "chart.bar.fill")
                }
                .accessibilityLabel("\(localization.localized("finances")) Tab")
            
            IssuesView()
                .tabItem {
                    Label(localization.localized("maintenance"), systemImage: "wrench.fill")
                }
                .accessibilityLabel("\(localization.localized("maintenance")) Tab")
            
            DocumentsView()
                .tabItem {
                    Label(localization.localized("documents"), systemImage: "doc.fill")
                }
                .accessibilityLabel("\(localization.localized("documents")) Tab")
            
            MessagesView()
                .tabItem {
                    Label(localization.localized("messages"), systemImage: "message.fill")
                }
                .accessibilityLabel("\(localization.localized("messages")) Tab")
            
            VideoUploadView()
                .tabItem {
                    Label(localization.localized("videos"), systemImage: "video.fill")
                }
                .accessibilityLabel("\(localization.localized("videos")) Tab")
            
            HistoryView()
                .tabItem {
                    Label(localization.localized("history"), systemImage: "clock.fill")
                }
                .accessibilityLabel("\(localization.localized("history")) Tab")
            
            MapView(authentication: authentication)
                .tabItem {
                    Label(localization.localized("maps"), systemImage: "map.fill")
                }
                .accessibilityLabel("\(localization.localized("maps")) Tab")
            
            ProfileView(authentication: authentication)
                .tabItem {
                    Label(localization.localized("profile"), systemImage: "person.fill")
                }
                .accessibilityLabel("\(localization.localized("profile")) Tab")
        }
        .tint(Color(.systemBlue))
    }
}

struct ProfileView: View {
    @ObservedObject var authentication: UserAuthentication
    @Environment(\.sizeCategory) var sizeCategory
    @State private var showLogoutConfirmation = false
    @State private var showLanguageSheet = false
    @ObservedObject private var localization = LocalizationManager.shared
    
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
                    
                    Text(localization.localized("welcome"))
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("\(localization.localized("logged_in_as")) \(authentication.currentUsername)")
                        .font(.body)
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.bottom, 8)
                    
                    // User information would go here in a real app
                    VStack(alignment: .leading, spacing: 12) {
                        ProfileInfoRow(icon: "envelope.fill", label: localization.localized("email"), value: "user@example.com")
                        ProfileInfoRow(icon: "phone.fill", label: localization.localized("phone"), value: "(555) 123-4567")
                        ProfileInfoRow(icon: "building.2.fill", label: localization.localized("company"), value: "VTS Inc.")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Language Selection Button
                    Button(action: {
                        showLanguageSheet = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                            Text(localization.localized("language"))
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .accessibilityHint("Double tap to change language settings")
                    
                    Spacer()
                    
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Label(localization.localized("logout"), systemImage: "rectangle.portrait.and.arrow.right")
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
            .navigationTitle(localization.localized("profile"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(localization.localized("confirm_logout"), isPresented: $showLogoutConfirmation) {
                Button(localization.localized("cancel"), role: .cancel) {}
                Button(localization.localized("logout"), role: .destructive) {
                    withAnimation {
                        authentication.logout()
                    }
                }
            } message: {
                Text(localization.localized("logout_message"))
            }
            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionView(isPresented: $showLanguageSheet)
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
            ContentView()
                .previewDisplayName("Default")
            
            ContentView()
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            ContentView()
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDisplayName("Large Text")
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var selectedLanguage: String
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguageCode)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach<[String], String, Button<HStack<TupleView<(Text, Spacer, Optional<Image>)>>>>(localization.supportedLanguages.keys.sorted(), id: \.self) { key in
                    Button(action: {
                        selectedLanguage = key
                        localization.changeLanguage(languageCode: key)
                    }) {
                        HStack {
                            Text(localization.supportedLanguages[key] ?? key)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedLanguage == key {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(localization.localized("select_language"), displayMode: .inline)
            .navigationBarItems(trailing: Button(localization.localized("done")) {
                isPresented = false
            })
        }
    }
}