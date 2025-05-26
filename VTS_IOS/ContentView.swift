import SwiftUI

struct ContentView: View {
    @ObservedObject var authentication: UserAuthentication
    
    var body: some View {
        TabView {
            PaymentsView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Payments")
                }
            
            IssuesView()
                .tabItem {
                    Image(systemName: "exclamationmark.circle")
                    Text("Issues")
                }
            
            VideoUploadView()
                .tabItem {
                    Image(systemName: "video")
                    Text("Videos")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            ProfileView(authentication: authentication)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct ProfileView: View {
    @ObservedObject var authentication: UserAuthentication
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Welcome to VTS iOS App")
                    .font(.title)
                    .padding()
                
                Text("You are logged in as \(authentication.currentUsername)")
                    .font(.subheadline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    authentication.logout()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authentication: UserAuthentication())
    }
}