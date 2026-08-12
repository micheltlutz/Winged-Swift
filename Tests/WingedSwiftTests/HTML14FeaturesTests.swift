import Foundation
import Testing
@testable import WingedSwift

@Suite struct HTML14FeaturesTests {

    @Test func testRawHTMLRendersWithoutWrapper() {
        let raw = RawHTML("<span class=\"x\">hi</span>")
        #expect(raw.render() == "<span class=\"x\">hi</span>")
        #expect(!(raw.render().contains("<div")))
    }

    @Test func testRawHTMLAsChildHasNoWrapper() {
        let div = Div(children: [
            RawHTML("<i class=\"fa fa-home\"></i>"),
            Span(content: "Home")
        ])
        #expect(div.render() == "<div><i class=\"fa fa-home\"></i><span>Home</span></div>")
    }

    @Test func testBooleanAttribute() {
        let input = Input(type: "checkbox", name: "agree", attributes: [
            Attribute.boolean("checked"),
            Attribute.boolean("required")
        ])
        let html = input.render()
        #expect(html.contains(" checked"))
        #expect(html.contains(" required"))
        #expect(!(html.contains("checked=")))
        #expect(!(html.contains("required=")))
    }

    @Test func testHTML5SelfClosingDefault() {
        let img = Img(src: "a.png", alt: "A")
        #expect(img.render() == "<img src=\"a.png\" alt=\"A\">")
        #expect(!(img.render().contains("/>")))
    }

    @Test func testXHTMLSelfClosingOption() {
        let img = Img(src: "a.png", alt: "A")
        #expect(img.render(RenderOptions(xhtmlSelfClosing: true)) == "<img src=\"a.png\" alt=\"A\" />")
    }

    @Test func testFragmentHelper() {
        let frag = fragment {
            I(attributes: [Attribute(key: "class", value: "fa fa-star")])
            Span(content: " Featured")
        }
        #expect(frag.render() == "<i class=\"fa fa-star\"></i><span> Featured</span>")
    }

    @Test func testFragmentBuilderBuildArray() {
        let cards = ["One", "Two", "Three"].map { title in
            Div(attributes: [Attribute(key: "class", value: "card")], content: title)
        }
        let frag = fragment {
            for card in cards {
                card
            }
        }
        #expect(frag.render() == "<div class=\"card\">One</div><div class=\"card\">Two</div><div class=\"card\">Three</div>")
    }

    @Test func testIAndAWithChildren() {
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

        #expect(link.render() == "<a href=\"/news\"><img src=\"thumb.jpg\" alt=\"Thumb\"></a>")
        #expect(heading.render() == "<h3><a href=\"/news\">Headline</a></h3>")
        #expect(icon.render() == "<i class=\"fas fa-search\"></i>")
    }

    @Test func testButtonSubmitType() {
        let submit = Button(type: "submit", content: "Send")
        #expect(submit.render() == "<button type=\"submit\">Send</button>")
    }

    @Test func testLabelWithoutFor() {
        let label = Label(content: "Accept cookies")
        #expect(label.render() == "<label>Accept cookies</label>")
        #expect(!(label.render().contains("for=")))
    }

    @Test func testInputWithoutName() {
        let search = Input(type: "search", attributes: [
            Attribute(key: "placeholder", value: "Search")
        ])
        #expect(search.render() == "<input type=\"search\" placeholder=\"Search\">")
        #expect(!(search.render().contains("name=")))
    }

    @Test func testSectionWithContent() {
        let section = Section(
            attributes: [Attribute(key: "class", value: "hero")],
            content: "Hello"
        )
        #expect(section.render() == "<section class=\"hero\">Hello</section>")
    }

    @Test func testInlineSemanticTags() {
        #expect(Strong(content: "bold").render() == "<strong>bold</strong>")
        #expect(Em(content: "emph").render() == "<em>emph</em>")
        #expect(Small(content: "fine").render() == "<small>fine</small>")
        #expect(Br().render() == "<br>")
        #expect(Hr().render() == "<hr>")
    }
}
