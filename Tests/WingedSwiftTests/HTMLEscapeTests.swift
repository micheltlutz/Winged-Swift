import XCTest
@testable import WingedSwift

final class HTMLEscapeTests: XCTestCase {
    func testEscapeBasicHTML() {
        // Given
        let unsafe = "<script>alert('XSS')</script>"
        
        // When
        let safe = HTMLEscape.escape(unsafe)
        
        // Then
        XCTAssertEqual(safe, "&lt;script&gt;alert(&#x27;XSS&#x27;)&lt;&#x2F;script&gt;")
    }
    
    func testEscapeAmpersand() {
        // Given
        let text = "Tom & Jerry"
        
        // When
        let escaped = HTMLEscape.escape(text)
        
        // Then
        XCTAssertEqual(escaped, "Tom &amp; Jerry")
    }
    
    func testEscapeQuotes() {
        // Given
        let text = "He said \"Hello\""
        
        // When
        let escaped = HTMLEscape.escape(text)
        
        // Then
        XCTAssertEqual(escaped, "He said &quot;Hello&quot;")
    }
    
    func testHTMLTagEscapesContentByDefault() {
        // Given
        let p = P(content: "<script>alert('XSS')</script>")
        
        // When
        let result = p.render()
        
        // Then
        XCTAssertFalse(result.contains("<script>"))
        XCTAssertTrue(result.contains("&lt;script&gt;"))
    }
    
    func testHTMLTagCanDisableEscape() {
        // Given
        let p = P(content: "<b>Bold</b>", escapeContent: false)
        
        // When
        let result = p.render()
        
        // Then
        XCTAssertTrue(result.contains("<b>Bold</b>"))
    }
    
    func testAttributeEscape() {
        // Given
        let value = "value with \"quotes\""
        
        // When
        let escaped = HTMLEscape.escapeAttribute(value)
        
        // Then
        XCTAssertEqual(escaped, "value with &quot;quotes&quot;")
    }
}

