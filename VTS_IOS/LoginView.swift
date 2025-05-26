import SwiftUI

struct LoginView: View {
    @ObservedObject var authentication: UserAuthentication
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingLoginError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .imageScale(.large)
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                
                Text("VTS iOS App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button(action: {
                    authenticateUser()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Text("Default credentials: admin/admin")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .alert(isPresented: $showingLoginError) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text("Invalid username or password. Please try again."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarHidden(true)
        }
    }
    
    private func authenticateUser() {
        if authentication.login(username: username, password: password) {
            // Login successful, authentication.isAuthenticated will be set to true
        } else {
            showingLoginError = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authentication: UserAuthentication())
    }
}