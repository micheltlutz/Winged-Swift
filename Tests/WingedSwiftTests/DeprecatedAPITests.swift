import Foundation
import XCTest
@testable import WingedSwift

/// 1.x call sites keep compiling and keep producing identical markup.
///
/// This is the one suite still written in XCTest: Swift Testing rejects `@available(*, deprecated)`
/// on `@Suite`/`@Test`, and without it every call here would raise a deprecation warning. The
/// deprecated API has to be exercised somewhere, so it is exercised in the one place that can
/// silence the warnings.
@available(*, deprecated)
final class DeprecatedAPITests: XCTestCase {

    func testRenderPrettyMatchesTheNewAPI() {
        let div = Div(children: [P(content: "Hi")])

        XCTAssertEqual(div.render(pretty: true), div.render(.pretty))
        XCTAssertEqual(div.render(pretty: false), div.render(.compact))
    }

    func testRenderCompactAndRenderPrettyStillWork() {
        let div = Div(children: [P(content: "Hi")])
        let indent = String(repeating: " ", count: 2)

        XCTAssertEqual(div.renderCompact(), "<div><p>Hi</p></div>")
        XCTAssertEqual(div.renderPretty(), "<div>\n\(indent)<p>Hi</p>\n</div>")
    }

    func testIndentLevelIsStillHonoured() {
        let div = Div(children: [P(content: "Hi")])
        let indent = String(repeating: " ", count: 2)

        XCTAssertEqual(
            div.renderPretty(indentLevel: 1),
            "\(indent)<div>\n\(indent + indent)<p>Hi</p>\n\(indent)</div>"
        )
    }

    func testGlobalXHTMLSwitchStillAffectsTheNoArgumentRender() {
        HTMLTag.xhtmlSelfClosing = true
        defer { HTMLTag.xhtmlSelfClosing = false }

        XCTAssertEqual(Img(src: "a.png").render(), "<img src=\"a.png\" />")
        // An explicit options value always wins over the global.
        XCTAssertEqual(Img(src: "a.png").render(.compact), "<img src=\"a.png\">")
    }

    func testAttributesBuilderInitStillWorks() {
        let tag = HTMLTag("dialog") {
            Attribute(key: "id", value: "confirm")
        }

        XCTAssertEqual(tag.render(), "<dialog id=\"confirm\"></dialog>")
    }

    func testLabelledAttributesBuilderIsTheReplacement() {
        let tag = HTMLTag("dialog", attributes: {
            Attribute(key: "id", value: "confirm")
        })

        XCTAssertEqual(tag.render(), "<dialog id=\"confirm\"></dialog>")
    }

    func testOneOnePageStillRendersTheSame() {
        // Written exactly as a 1.x site would.
        let page = html {
            Head(children: [
                Meta(charset: "UTF-8"),
                Title(content: "Home")
            ])
            Body(children: [
                MainTag(children: [
                    H1(content: "Hello"),
                    P(content: "Tom & Jerry")
                ])
            ])
        }

        XCTAssertEqual(
            page.render(),
            "<html><head><meta charset=\"UTF-8\"><title>Home</title></head>"
            + "<body><main><h1>Hello</h1><p>Tom &amp; Jerry</p></main></body></html>"
        )
    }
}
