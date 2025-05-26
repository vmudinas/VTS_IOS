import SwiftUI

struct MainView: View {
    @ObservedObject var authentication = UserAuthentication()
    
    var body: some View {
        if authentication.isAuthenticated {
            ContentView(authentication: authentication)
        } else {
            LoginView(authentication: authentication)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}