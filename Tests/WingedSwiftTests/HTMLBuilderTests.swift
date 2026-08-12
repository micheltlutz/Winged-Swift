import Foundation
import Testing
@testable import WingedSwift

@Suite struct HTMLBuilderTests {
    @Test func testHTMLBuilderCreatesRootHTMLTag() {
        // Given
        let expectedTagName = "html"
        
        // When
        let document = html {
            HTMLTag("body")
            HTMLTag("head")
        }
        
        // Then
        #expect(document.name == expectedTagName, "Root tag should be 'html'")
        #expect(document.children.count == 2, "Root tag should have two children.")
        #expect(document.children[0].name == "body", "First child should be 'body'")
        #expect(document.children[1].name == "head", "Second child should be 'head'")
    }
    
    @Test func testHTMLBuilderHandlesOptional() {
        // Given
        let optionalComponent: HTMLTag? = HTMLTag("optional")
        
        // When
        let document = html {
            HTMLBuilder.buildOptional(optionalComponent)
        }
        
        // Then
        #expect(document.name == "html", "Root tag should be 'html'")
        #expect(document.children.count == 1, "Root tag should have one child.")
        #expect(document.children[0].name == "optional", "Child tag should be 'optional'")
    }
    
    @Test func testHTMLBuilderHandlesEitherFirst() {
        // When
        let document = html {
            HTMLBuilder.buildEither(first: HTMLTag("first"))
        }
        
        // Then
        #expect(document.name == "html", "Root tag should be 'html'")
        #expect(document.children.count == 1, "Root tag should have one child.")
        #expect(document.children[0].name == "first", "Child tag should be 'first'")
    }
    
    @Test func testHTMLBuilderHandlesEitherSecond() {
        // When
        let document = html {
            HTMLBuilder.buildEither(second: HTMLTag("second"))
        }
        
        // Then
        #expect(document.name == "html", "Root tag should be 'html'")
        #expect(document.children.count == 1, "Root tag should have one child.")
        #expect(document.children[0].name == "second", "Child tag should be 'second'")
    }
}
