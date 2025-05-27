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
                "payments": "Payments",
                "issue": "Issue",
                "maintenance": "Maintenance",
                "message": "Message",
                "messages": "Messages",
                "document": "Document",
                "documents": "Documents",
                "settings": "Settings",
                "offline": "Offline Mode",
                "sync": "Sync",
                "send": "Send",
                "amount": "Amount",
                "due_date": "Due Date",
                "recurring": "Recurring",
                "finances": "Finances",
                "videos": "Videos",
                "history": "History",
                "maps": "Maps",
                "profile": "Profile",
                "welcome": "Welcome to VTS iOS App",
                "logged_in_as": "You are logged in as",
                "email": "Email",
                "phone": "Phone",
                "company": "Company",
                "logout": "Logout",
                "confirm_logout": "Confirm Logout",
                "logout_message": "Are you sure you want to log out?",
                "cancel": "Cancel",
                "username": "Username",
                "password": "Password",
                "login": "Login",
                "logging_in": "Logging in...",
                "show_password": "Show password",
                "hide_password": "Hide password",
                "language": "Language",
                "select_language": "Select Language",
                "upcoming": "Upcoming",
                "paid": "Paid",
                "via": "via",
                "refunded": "Refunded",
                "back": "Back",
                "done": "Done"
            ],
            "es": [
                "payment": "Pago",
                "payments": "Pagos",
                "issue": "Problema",
                "maintenance": "Mantenimiento",
                "message": "Mensaje",
                "messages": "Mensajes",
                "document": "Documento",
                "documents": "Documentos",
                "settings": "Configuración",
                "offline": "Modo sin conexión",
                "sync": "Sincronizar",
                "send": "Enviar",
                "amount": "Cantidad",
                "due_date": "Fecha de vencimiento",
                "recurring": "Recurrente",
                "finances": "Finanzas",
                "videos": "Videos",
                "history": "Historial",
                "maps": "Mapas",
                "profile": "Perfil",
                "welcome": "Bienvenido a la aplicación VTS iOS",
                "logged_in_as": "Has iniciado sesión como",
                "email": "Correo",
                "phone": "Teléfono",
                "company": "Empresa",
                "logout": "Cerrar sesión",
                "confirm_logout": "Confirmar cierre de sesión",
                "logout_message": "¿Estás seguro de que quieres cerrar sesión?",
                "cancel": "Cancelar",
                "username": "Nombre de usuario",
                "password": "Contraseña",
                "login": "Iniciar sesión",
                "logging_in": "Iniciando sesión...",
                "show_password": "Mostrar contraseña",
                "hide_password": "Ocultar contraseña",
                "language": "Idioma",
                "select_language": "Seleccionar idioma",
                "upcoming": "Próximos",
                "paid": "Pagado",
                "via": "vía",
                "refunded": "Reembolsado",
                "back": "Atrás",
                "done": "Hecho"
            ],
            "fr": [
                "payment": "Paiement",
                "payments": "Paiements",
                "issue": "Problème",
                "maintenance": "Entretien",
                "message": "Message",
                "messages": "Messages",
                "document": "Document",
                "documents": "Documents",
                "settings": "Paramètres",
                "offline": "Mode hors ligne",
                "sync": "Synchroniser",
                "send": "Envoyer",
                "amount": "Montant",
                "due_date": "Échéance",
                "recurring": "Récurrent",
                "finances": "Finances",
                "videos": "Vidéos",
                "history": "Historique",
                "maps": "Cartes",
                "profile": "Profil",
                "welcome": "Bienvenue sur l'application VTS iOS",
                "logged_in_as": "Vous êtes connecté en tant que",
                "email": "E-mail",
                "phone": "Téléphone",
                "company": "Société",
                "logout": "Déconnexion",
                "confirm_logout": "Confirmer la déconnexion",
                "logout_message": "Êtes-vous sûr de vouloir vous déconnecter?",
                "cancel": "Annuler",
                "username": "Nom d'utilisateur",
                "password": "Mot de passe",
                "login": "Connexion",
                "logging_in": "Connexion en cours...",
                "show_password": "Afficher le mot de passe",
                "hide_password": "Masquer le mot de passe",
                "language": "Langue",
                "select_language": "Sélectionner la langue",
                "upcoming": "À venir",
                "paid": "Payé",
                "via": "via",
                "refunded": "Remboursé",
                "back": "Retour",
                "done": "Terminé"
            ],
            "de": [
                "payment": "Zahlung",
                "payments": "Zahlungen",
                "issue": "Problem",
                "maintenance": "Wartung",
                "message": "Nachricht",
                "messages": "Nachrichten",
                "document": "Dokument",
                "documents": "Dokumente",
                "settings": "Einstellungen",
                "offline": "Offline-Modus",
                "sync": "Synchronisieren",
                "send": "Senden",
                "amount": "Betrag",
                "due_date": "Fälligkeitsdatum",
                "recurring": "Wiederkehrend",
                "finances": "Finanzen",
                "videos": "Videos",
                "history": "Verlauf",
                "maps": "Karten",
                "profile": "Profil",
                "welcome": "Willkommen bei der VTS iOS App",
                "logged_in_as": "Sie sind angemeldet als",
                "email": "E-Mail",
                "phone": "Telefon",
                "company": "Firma",
                "logout": "Abmelden",
                "confirm_logout": "Abmeldung bestätigen",
                "logout_message": "Sind Sie sicher, dass Sie sich abmelden möchten?",
                "cancel": "Abbrechen",
                "username": "Benutzername",
                "password": "Passwort",
                "login": "Anmelden",
                "logging_in": "Anmeldung läuft...",
                "show_password": "Passwort anzeigen",
                "hide_password": "Passwort verbergen",
                "language": "Sprache",
                "select_language": "Sprache auswählen",
                "upcoming": "Bevorstehend",
                "paid": "Bezahlt",
                "via": "über",
                "refunded": "Erstattet",
                "back": "Zurück",
                "done": "Fertig"
            ],
            "zh": [
                "payment": "支付",
                "payments": "支付",
                "issue": "问题",
                "maintenance": "维护",
                "message": "消息",
                "messages": "消息",
                "document": "文档",
                "documents": "文档",
                "settings": "设置",
                "offline": "离线模式",
                "sync": "同步",
                "send": "发送",
                "amount": "金额",
                "due_date": "截止日期",
                "recurring": "定期",
                "finances": "财务",
                "videos": "视频",
                "history": "历史",
                "maps": "地图",
                "profile": "个人资料",
                "welcome": "欢迎使用VTS iOS应用",
                "logged_in_as": "您已登录为",
                "email": "电子邮件",
                "phone": "电话",
                "company": "公司",
                "logout": "登出",
                "confirm_logout": "确认登出",
                "logout_message": "您确定要登出吗？",
                "cancel": "取消",
                "username": "用户名",
                "password": "密码",
                "login": "登录",
                "logging_in": "正在登录...",
                "show_password": "显示密码",
                "hide_password": "隐藏密码",
                "language": "语言",
                "select_language": "选择语言",
                "upcoming": "即将到来",
                "paid": "已付",
                "via": "通过",
                "refunded": "已退款",
                "back": "返回",
                "done": "完成"
            ]
        ]
        
        // Default to English if language not supported or key not found
        return localizedStrings[currentLanguageCode]?[key] ?? localizedStrings["en"]?[key] ?? key
    }
}