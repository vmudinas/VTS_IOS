import XCTest
import SwiftUI
@testable import VTS_IOS

class ContentViewTests: XCTestCase {
    
    func testContentViewInitializes() {
        // Create the content view
        let contentView = ContentView()
        
        // Check that it initializes properly
        XCTAssertNotNil(contentView)
    }
}