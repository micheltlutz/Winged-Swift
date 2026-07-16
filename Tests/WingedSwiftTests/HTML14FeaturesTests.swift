import XCTest
@testable import WingedSwift

final class HTML14FeaturesTests: XCTestCase {

    override func tearDown() {
        HTMLTag.xhtmlSelfClosing = false
        super.tearDown()
    }

    func testRawHTMLRendersWithoutWrapper() {
        let raw = RawHTML("<span class=\"x\">hi</span>")
        XCTAssertEqual(raw.render(), "<span class=\"x\">hi</span>")
        XCTAssertFalse(raw.render().contains("<div"))
    }

    func testRawHTMLAsChildHasNoWrapper() {
        let div = Div(children: [
            RawHTML("<i class=\"fa fa-home\"></i>"),
            Span(content: "Home")
        ])
        XCTAssertEqual(div.render(), "<div><i class=\"fa fa-home\"></i><span>Home</span></div>")
    }

    func testBooleanAttribute() {
        let input = Input(type: "checkbox", name: "agree", attributes: [
            Attribute.boolean("checked"),
            Attribute.boolean("required")
        ])
        let html = input.render()
        XCTAssertTrue(html.contains(" checked"))
        XCTAssertTrue(html.contains(" required"))
        XCTAssertFalse(html.contains("checked="))
        XCTAssertFalse(html.contains("required="))
    }

    func testHTML5SelfClosingDefault() {
        let img = Img(src: "a.png", alt: "A")
        XCTAssertEqual(img.render(), "<img src=\"a.png\" alt=\"A\">")
        XCTAssertFalse(img.render().contains("/>"))
    }

    func testXHTMLSelfClosingFlag() {
        HTMLTag.xhtmlSelfClosing = true
        let img = Img(src: "a.png", alt: "A")
        XCTAssertEqual(img.render(), "<img src=\"a.png\" alt=\"A\" />")
        HTMLTag.xhtmlSelfClosing = false
    }

    func testFragmentHelper() {
        let frag = fragment {
            I(attributes: [Attribute(key: "class", value: "fa fa-star")])
            Span(content: " Featured")
        }
        XCTAssertEqual(frag.render(), "<i class=\"fa fa-star\"></i><span> Featured</span>")
    }

    func testFragmentBuilderBuildArray() {
        let cards = ["One", "Two", "Three"].map { title in
            Div(attributes: [Attribute(key: "class", value: "card")], content: title)
        }
        let frag = fragment {
            for card in cards {
                card
            }
        }
        XCTAssertEqual(
            frag.render(),
            "<div class=\"card\">One</div><div class=\"card\">Two</div><div class=\"card\">Three</div>"
        )
    }

    func testIAndAWithChildren() {
        let link = A(
            href: "/news",
            children: [
                Img(src: "thumb.jpg", alt: "Thumb")
            ]
        )
        let heading = H3(children: [
            A(href: "/news", content: "Headline")
        ])
        let icon = I(attributes: [Attribute(key: "class", value: "fas fa-search")])

        XCTAssertEqual(link.render(), "<a href=\"/news\"><img src=\"thumb.jpg\" alt=\"Thumb\"></a>")
        XCTAssertEqual(heading.render(), "<h3><a href=\"/news\">Headline</a></h3>")
        XCTAssertEqual(icon.render(), "<i class=\"fas fa-search\"></i>")
    }

    func testButtonSubmitType() {
        let submit = Button(type: "submit", content: "Send")
        XCTAssertEqual(submit.render(), "<button type=\"submit\">Send</button>")
    }

    func testLabelWithoutFor() {
        let label = Label(content: "Accept cookies")
        XCTAssertEqual(label.render(), "<label>Accept cookies</label>")
        XCTAssertFalse(label.render().contains("for="))
    }

    func testInputWithoutName() {
        let search = Input(type: "search", attributes: [
            Attribute(key: "placeholder", value: "Search")
        ])
        XCTAssertEqual(search.render(), "<input type=\"search\" placeholder=\"Search\">")
        XCTAssertFalse(search.render().contains("name="))
    }

    func testSectionWithContent() {
        let section = Section(
            attributes: [Attribute(key: "class", value: "hero")],
            content: "Hello"
        )
        XCTAssertEqual(section.render(), "<section class=\"hero\">Hello</section>")
    }

    func testInlineSemanticTags() {
        XCTAssertEqual(Strong(content: "bold").render(), "<strong>bold</strong>")
        XCTAssertEqual(Em(content: "emph").render(), "<em>emph</em>")
        XCTAssertEqual(Small(content: "fine").render(), "<small>fine</small>")
        XCTAssertEqual(Br().render(), "<br>")
        XCTAssertEqual(Hr().render(), "<hr>")
    }
}
