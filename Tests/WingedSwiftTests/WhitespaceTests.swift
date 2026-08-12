import Foundation
import Testing
@testable import WingedSwift

/// Pretty printing must never add whitespace inside elements that render it,
/// otherwise code blocks gain phantom indentation in the browser.
@Suite struct WhitespaceTests {

    @Test func testPreWithCodeChildIsNotIndented() {
        let block = Pre(attributes: [], content: nil)
        block.addChild(Code(content: "let x = 1"))

        #expect(block.render(.pretty) == "<pre><code>let x = 1</code></pre>")
    }

    @Test func testPrettyMatchesCompactForWhitespaceSensitiveTags() {
        let block = Pre()
        block.addChild(Code(attributes: [Attribute(key: "class", value: "language-swift")],
                            content: "print(\"hi\")"))

        #expect(block.render(.pretty) == block.render(.compact))
    }

    @Test func testTextareaKeepsItsContentIntact() {
        let field = Textarea(name: "bio", content: "line 1\nline 2")

        #expect(field.render(.pretty) == "<textarea name=\"bio\">line 1\nline 2</textarea>")
    }

    @Test func testNestedInsideAPrettyDocumentKeepsOuterIndentation() {
        let container = Div(children: [Pre(children: [Code(content: "swift build")])])

        #expect(container.render(.pretty) == """
            <div>
              <pre><code>swift build</code></pre>
            </div>
            """)
    }
}
