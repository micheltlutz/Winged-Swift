import Foundation
import Testing
@testable import WingedSwift

@Suite struct HTMLEscapeTests {
    @Test func testEscapeBasicHTML() {
        // Given
        let unsafe = "<script>alert('XSS')</script>"
        
        // When
        let safe = HTMLEscape.escape(unsafe)
        
        // Then
        #expect(safe == "&lt;script&gt;alert(&#x27;XSS&#x27;)&lt;/script&gt;")
    }

    @Test func testSlashesAreKeptByDefault() {
        // Given
        let text = "Published on 11/08/2026 — see /docs/getting-started"

        // When
        let escaped = HTMLEscape.escape(text)

        // Then
        #expect(escaped == text)
    }

    @Test func testSlashesCanBeEscapedExplicitly() {
        // Given
        let text = "</script>"

        // When
        let escaped = HTMLEscape.escape(text, escapeSlashes: true)

        // Then
        #expect(escaped == "&lt;&#x2F;script&gt;")
    }

    @Test func testEscapeAmpersand() {
        // Given
        let text = "Tom & Jerry"
        
        // When
        let escaped = HTMLEscape.escape(text)
        
        // Then
        #expect(escaped == "Tom &amp; Jerry")
    }
    
    @Test func testEscapeQuotes() {
        // Given
        let text = "He said \"Hello\""
        
        // When
        let escaped = HTMLEscape.escape(text)
        
        // Then
        #expect(escaped == "He said &quot;Hello&quot;")
    }
    
    @Test func testHTMLTagEscapesContentByDefault() {
        // Given
        let p = P(content: "<script>alert('XSS')</script>")
        
        // When
        let result = p.render()
        
        // Then
        #expect(!(result.contains("<script>")))
        #expect(result.contains("&lt;script&gt;"))
    }
    
    @Test func testHTMLTagCanDisableEscape() {
        // Given
        let p = P(content: "<b>Bold</b>", escapeContent: false)
        
        // When
        let result = p.render()
        
        // Then
        #expect(result.contains("<b>Bold</b>"))
    }
    
    @Test func testAttributeEscape() {
        // Given
        let value = "value with \"quotes\""
        
        // When
        let escaped = HTMLEscape.escapeAttribute(value)
        
        // Then
        #expect(escaped == "value with &quot;quotes&quot;")
    }
}
