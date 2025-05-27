import SwiftUI

struct LoginView: View {
    @ObservedObject var authentication: UserAuthentication
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var localization = LocalizationManager.shared
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingLoginError = false
    @State private var isLoggingIn = false
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 20)
                    
                    // App Logo
                    Image(systemName: "lock.shield.fill")
                        .imageScale(.large)
                        .font(.system(size: 70))
                        .foregroundColor(Color(.systemBlue))
                        .padding(.bottom, 30)
                        .accessibilityHidden(true) // Hide from VoiceOver since it's decorative
                    
                    Text("VTS iOS App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 30)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Username Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.localized("username"))
                            .font(.callout)
                            .foregroundColor(Color(.secondaryLabel))
                            .accessibilityHidden(true)
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(.systemGray))
                                .frame(width: 20)
                                .accessibilityHidden(true)
                            
                            TextField(localization.localized("username"), text: $username)
                                .focused($focusedField, equals: .username)
                                .textContentType(.username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(focusedField == .username ? Color(.systemBlue) : Color.clear, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(localization.localized("password"))
                            .font(.callout)
                            .foregroundColor(Color(.secondaryLabel))
                            .accessibilityHidden(true)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(.systemGray))
                                .frame(width: 20)
                                .accessibilityHidden(true)
                            
                            Group {
                                if showPassword {
                                    TextField(localization.localized("password"), text: $password)
                                        .focused($focusedField, equals: .password)
                                        .textContentType(.password)
                                } else {
                                    SecureField(localization.localized("password"), text: $password)
                                        .focused($focusedField, equals: .password)
                                        .textContentType(.password)
                                }
                            }
                            .submitLabel(.done)
                            .onSubmit {
                                if !username.isEmpty && !password.isEmpty {
                                    authenticateUser()
                                } else {
                                    if username.isEmpty {
                                        focusedField = .username
                                    } else {
                                        focusedField = .password
                                    }
                                }
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Color(.systemGray))
                            }
                            .accessibilityLabel(showPassword ? localization.localized("hide_password") : localization.localized("show_password"))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(focusedField == .password ? Color(.systemBlue) : Color.clear, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Login Button
                    Button(action: {
                        authenticateUser()
                    }) {
                        HStack {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isLoggingIn ? localization.localized("logging_in") : localization.localized("login"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoggingIn)
                    .opacity((username.isEmpty || password.isEmpty || isLoggingIn) ? 0.6 : 1)
                    .accessibilityLabel(localization.localized("login"))
                    .accessibilityHint("Double tap to log into your account")
                    
                    Spacer()
                    
                    // Help Text
                    VStack(spacing: 8) {
                        Text("Default credentials: admin/admin")
                            .font(.caption)
                            .foregroundColor(Color(.systemGray))
                        
                        if showingLoginError {
                            Text("Invalid username or password. Please try again.")
                                .font(.caption)
                                .foregroundColor(Color(.systemRed))
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                                .accessibilityAddTraits(.isStaticText)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button(localization.localized("done")) {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                // Set focus to username field after a slight delay to ensure form is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .username
                }
            }
        }
    }
    
    private func authenticateUser() {
        // Hide the keyboard
        focusedField = nil
        
        // Show the loading state
        isLoggingIn = true
        showingLoginError = false
        
        // Simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let success = authentication.login(username: username, password: password)
            
            if !success {
                withAnimation {
                    showingLoginError = true
                }
            }
            
            isLoggingIn = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(authentication: UserAuthentication())
                .previewDisplayName("Default")
            
            LoginView(authentication: UserAuthentication())
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            LoginView(authentication: UserAuthentication())
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDisplayName("Large Text")
        }
    }
}