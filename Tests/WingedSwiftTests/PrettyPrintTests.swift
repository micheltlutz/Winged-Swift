import XCTest
@testable import WingedSwift

final class PrettyPrintTests: XCTestCase {
    func testPrettyPrintSimpleTag() {
        // Given
        let div = Div(content: "Hello World", escapeContent: false)
        
        // When
        let result = div.render(pretty: true)
        
        // Then
        XCTAssertEqual(result, "<div>Hello World</div>")
    }
    
    func testPrettyPrintWithChildren() {
        // Given
        let div = Div(children: [
            P(content: "Paragraph 1", escapeContent: false),
            P(content: "Paragraph 2", escapeContent: false)
        ])
        
        // When
        let result = div.render(pretty: true)
        
        // Then
        let expected = """
        <div>
          <p>Paragraph 1</p>
          <p>Paragraph 2</p>
        </div>
        """
        XCTAssertEqual(result, expected)
    }
    
    func testCompactRenderStillWorks() {
        // Given
        let div = Div(children: [
            P(content: "Test", escapeContent: false)
        ])
        
        // When
        let result = div.render(pretty: false)
        
        // Then
        XCTAssertEqual(result, "<div><p>Test</p></div>")
    }
    
    func testSelfClosingTagPrettyPrint() {
        // Given
        let img = Img(src: "test.jpg", alt: "Test")
        
        // When
        let result = img.render(pretty: true)
        
        // Then
        XCTAssertTrue(result.contains("<img"))
        XCTAssertTrue(result.contains("/>"))
    }
}
