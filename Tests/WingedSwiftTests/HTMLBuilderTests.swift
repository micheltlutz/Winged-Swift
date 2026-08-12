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
    
    @Test func testHTMLBuilderWrapsASingleNonGroupedComponent() {
        // buildOptional returns the tag itself rather than a Fragment, which html(_:) must adopt.
        let document = html {
            HTMLBuilder.buildOptional(Body(children: [H1(content: "Hi")]))
        }

        #expect(document.render() == "<html><body><h1>Hi</h1></body></html>")
    }

    @Test func testHTMLBuilderTakesBothBranchesOfAnIfElse() {
        func page(_ loggedIn: Bool) -> HTMLTag {
            html {
                if loggedIn {
                    Nav(content: "Sign out")
                } else {
                    Nav(content: "Sign in")
                }
            }
        }

        #expect(page(true).render() == "<html><nav>Sign out</nav></html>")
        #expect(page(false).render() == "<html><nav>Sign in</nav></html>")
    }

    @Test func testHTMLBuilderAcceptsAnArrayExpression() {
        let document = html {
            HTMLBuilder.buildExpression(["a", "b"].map { P(content: $0) })
        }

        #expect(document.render() == "<html><p>a</p><p>b</p></html>")
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
