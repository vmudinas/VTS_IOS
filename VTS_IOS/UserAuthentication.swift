import Foundation
import SwiftUI
import Combine

public class UserAuthentication: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUsername: String = ""
    
    // Default credentials - these would be replaced by external API call in the future
    private let defaultUsername = "admin"
    private let defaultPassword = "admin"
    
    func login(username: String, password: String) -> Bool {
        // For now, we'll just check against hardcoded credentials
        // In the future, this would call an external API
        let isValid = (username == defaultUsername && password == defaultPassword)
        
        if isValid {
            isAuthenticated = true
            currentUsername = username
        }
        
        return isValid
    }
    
    func logout() {
        isAuthenticated = false
        currentUsername = ""
    }
}