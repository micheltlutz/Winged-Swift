import XCTest
@testable import WingedSwift

final class HTMLBuilderTests: XCTestCase {
    func testHTMLBuilderCreatesRootHTMLTag() {
        // Given
        let expectedTagName = "html"
        
        // When
        let document = html {
            HTMLTag("body")
            HTMLTag("head")
        }
        
        // Then
        XCTAssertEqual(document.name, expectedTagName, "Root tag should be 'html'")
        XCTAssertEqual(document.children.count, 2, "Root tag should have two children.")
        XCTAssertEqual(document.children[0].name, "body", "First child should be 'body'")
        XCTAssertEqual(document.children[1].name, "head", "Second child should be 'head'")
    }
    
    func testHTMLBuilderHandlesOptional() {
        // Given
        let optionalComponent: HTMLTag? = HTMLTag("optional")
        
        // When
        let document = html {
            HTMLBuilder.buildOptional(optionalComponent)
        }
        
        // Then
        XCTAssertEqual(document.name, "html", "Root tag should be 'html'")
        XCTAssertEqual(document.children.count, 1, "Root tag should have one child.")
        XCTAssertEqual(document.children[0].name, "optional", "Child tag should be 'optional'")
    }
    
    func testHTMLBuilderHandlesEitherFirst() {
        // When
        let document = html {
            HTMLBuilder.buildEither(first: HTMLTag("first"))
        }
        
        // Then
        XCTAssertEqual(document.name, "html", "Root tag should be 'html'")
        XCTAssertEqual(document.children.count, 1, "Root tag should have one child.")
        XCTAssertEqual(document.children[0].name, "first", "Child tag should be 'first'")
    }
    
    func testHTMLBuilderHandlesEitherSecond() {
        // When
        let document = html {
            HTMLBuilder.buildEither(second: HTMLTag("second"))
        }
        
        // Then
        XCTAssertEqual(document.name, "html", "Root tag should be 'html'")
        XCTAssertEqual(document.children.count, 1, "Root tag should have one child.")
        XCTAssertEqual(document.children[0].name, "second", "Child tag should be 'second'")
    }
}
