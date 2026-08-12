import Foundation
import Testing
@testable import WingedSwift

@Suite struct PrettyPrintTests {
    @Test func testPrettyPrintSimpleTag() {
        // Given
        let div = Div(content: "Hello World", escapeContent: false)
        
        // When
        let result = div.render(.pretty)
        
        // Then
        #expect(result == "<div>Hello World</div>")
    }
    
    @Test func testPrettyPrintWithChildren() {
        // Given
        let div = Div(children: [
            P(content: "Paragraph 1", escapeContent: false),
            P(content: "Paragraph 2", escapeContent: false)
        ])
        
        // When
        let result = div.render(.pretty)
        
        // Then
        let expected = """
        <div>
          <p>Paragraph 1</p>
          <p>Paragraph 2</p>
        </div>
        """
        #expect(result == expected)
    }
    
    @Test func testCompactRenderStillWorks() {
        // Given
        let div = Div(children: [
            P(content: "Test", escapeContent: false)
        ])
        
        // When
        let result = div.render(.compact)
        
        // Then
        #expect(result == "<div><p>Test</p></div>")
    }
    
    @Test func testSelfClosingTagPrettyPrint() {
        // Given
        let img = Img(src: "test.jpg", alt: "Test")
        
        // When
        let result = img.render(.pretty)
        
        // Then
        #expect(result.contains("<img"))
        #expect(!(result.contains("/>")))
        #expect(result.hasSuffix(">"))
    }
}
