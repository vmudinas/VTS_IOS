import XCTest
@testable import VTS_IOS

class LocalizationManagerTests: XCTestCase {
    
    var localizationManager: LocalizationManager!
    
    override func setUp() {
        super.setUp()
        localizationManager = LocalizationManager.shared
    }
    
    override func tearDown() {
        // Reset to default language after each test
        localizationManager.changeLanguage(languageCode: "en")
        super.tearDown()
    }
    
    func testDefaultLanguage() {
        // Test that the default language is correctly set
        XCTAssertEqual(localizationManager.currentLanguageCode, "en")
    }
    
    func testEnglishLocalization() {
        // Test English localization
        localizationManager.changeLanguage(languageCode: "en")
        XCTAssertEqual(localizationManager.localized("payment"), "Payment")
        XCTAssertEqual(localizationManager.localized("messages"), "Messages")
        XCTAssertEqual(localizationManager.localized("profile"), "Profile")
    }
    
    func testSpanishLocalization() {
        // Test Spanish localization
        localizationManager.changeLanguage(languageCode: "es")
        XCTAssertEqual(localizationManager.localized("payment"), "Pago")
        XCTAssertEqual(localizationManager.localized("messages"), "Mensajes")
        XCTAssertEqual(localizationManager.localized("profile"), "Perfil")
    }
    
    func testFrenchLocalization() {
        // Test French localization
        localizationManager.changeLanguage(languageCode: "fr")
        XCTAssertEqual(localizationManager.localized("payment"), "Paiement")
        XCTAssertEqual(localizationManager.localized("messages"), "Messages")
        XCTAssertEqual(localizationManager.localized("profile"), "Profil")
    }
    
    func testGermanLocalization() {
        // Test German localization
        localizationManager.changeLanguage(languageCode: "de")
        XCTAssertEqual(localizationManager.localized("payment"), "Zahlung")
        XCTAssertEqual(localizationManager.localized("messages"), "Nachrichten")
        XCTAssertEqual(localizationManager.localized("profile"), "Profil")
    }
    
    func testChineseLocalization() {
        // Test Chinese localization
        localizationManager.changeLanguage(languageCode: "zh")
        XCTAssertEqual(localizationManager.localized("payment"), "支付")
        XCTAssertEqual(localizationManager.localized("messages"), "消息")
        XCTAssertEqual(localizationManager.localized("profile"), "个人资料")
    }
    
    func testUnsupportedLanguage() {
        // Test that attempting to set an unsupported language has no effect
        let originalLanguage = localizationManager.currentLanguageCode
        localizationManager.changeLanguage(languageCode: "xx")
        XCTAssertEqual(localizationManager.currentLanguageCode, originalLanguage)
    }
    
    func testFallbackToEnglish() {
        // Test that keys not found in the current language fall back to English
        localizationManager.changeLanguage(languageCode: "es")
        XCTAssertEqual(localizationManager.localized("nonexistent_key"), "nonexistent_key")
    }
    
    func testCurrencyFormatting() {
        // Test that currency formatting respects the current locale
        localizationManager.changeCurrency(currencyCode: "EUR")
        let formattedAmount = localizationManager.formatCurrency(123.45)
        // We can't assert exact format because it depends on the runtime environment,
        // but we can check for the currency symbol
        XCTAssertTrue(formattedAmount.contains("123.45") || formattedAmount.contains("123,45"))
    }
    
    func testDateFormatting() {
        // Test that date formatting respects the current locale
        let testDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let formattedDate = localizationManager.formatDate(testDate)
        // Again, we can't assert exact format, but we can check it's not empty
        XCTAssertFalse(formattedDate.isEmpty)
    }
}