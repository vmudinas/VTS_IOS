import SwiftUI

struct ContentView: View {
    @ObservedObject var authentication: UserAuthentication
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding()
                
                Text("Welcome to VTS iOS App")
                    .font(.title)
                    .padding()
                
                Text("You are successfully logged in!")
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
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(authentication: UserAuthentication())
    }
}