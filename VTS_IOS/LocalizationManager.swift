import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLocale: Locale
    @Published var currentLanguageCode: String
    @Published var currentCurrencyCode: String
    
    // Supported languages
    let supportedLanguages = [
        "en": "English",
        "es": "Español",
        "fr": "Français",
        "de": "Deutsch",
        "zh": "中文"
    ]
    
    // Supported currencies
    let supportedCurrencies = [
        "USD": "US Dollar ($)",
        "EUR": "Euro (€)",
        "GBP": "British Pound (£)",
        "CAD": "Canadian Dollar (CA$)",
        "AUD": "Australian Dollar (A$)",
        "CNY": "Chinese Yuan (¥)"
    ]
    
    private init() {
        // Get the user's preferred locale
        currentLocale = Locale.current
        currentLanguageCode = currentLocale.languageCode ?? "en"
        currentCurrencyCode = currentLocale.currency?.identifier ?? "USD"
    }
    
    // MARK: - Localization Methods
    
    // Format currency based on current locale settings
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = currentLocale
        formatter.currencyCode = currentCurrencyCode
        
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    // Format date based on current locale settings
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = currentLocale
        
        return formatter.string(from: date)
    }
    
    // Change the current language
    func changeLanguage(languageCode: String) {
        guard supportedLanguages.keys.contains(languageCode) else { return }
        
        self.currentLanguageCode = languageCode
        
        // In a real app, this would update the app's language
        // and reload localized strings
        if let languageID = Locale(identifier: languageCode).languageCode {
            UserDefaults.standard.set([languageID], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Change the current currency
    func changeCurrency(currencyCode: String) {
        guard supportedCurrencies.keys.contains(currencyCode) else { return }
        
        self.currentCurrencyCode = currencyCode
        
        // Save to UserDefaults
        UserDefaults.standard.set(currencyCode, forKey: "PreferredCurrency")
        UserDefaults.standard.synchronize()
    }
    
    // Translate a key to the current language
    // In a real app, this would use the NSLocalizedString system
    // For our mock implementation, we'll use a simple dictionary
    func localized(_ key: String) -> String {
        let localizedStrings: [String: [String: String]] = [
            "en": [
                "payment": "Payment",
                "issue": "Issue",
                "message": "Message",
                "document": "Document",
                "settings": "Settings",
                "offline": "Offline Mode",
                "sync": "Sync",
                "send": "Send"
            ],
            "es": [
                "payment": "Pago",
                "issue": "Problema",
                "message": "Mensaje",
                "document": "Documento",
                "settings": "Configuración",
                "offline": "Modo sin conexión",
                "sync": "Sincronizar",
                "send": "Enviar"
            ],
            "fr": [
                "payment": "Paiement",
                "issue": "Problème",
                "message": "Message",
                "document": "Document",
                "settings": "Paramètres",
                "offline": "Mode hors ligne",
                "sync": "Synchroniser",
                "send": "Envoyer"
            ]
        ]
        
        // Default to English if language not supported or key not found
        return localizedStrings[currentLanguageCode]?[key] ?? localizedStrings["en"]?[key] ?? key
    }
}