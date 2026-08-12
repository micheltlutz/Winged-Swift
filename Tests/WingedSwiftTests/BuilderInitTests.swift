import Foundation
import Testing
@testable import WingedSwift

/// The builder initializer must be exactly equivalent to the array one, for every family of tags.
@Suite struct BuilderInitTests {

    @Test func plainContainer() {
        let builder = Div { P(content: "Hi") }
        let array = Div(children: [P(content: "Hi")])

        #expect(builder.render() == array.render())
        #expect(builder.render() == "<div><p>Hi</p></div>")
    }

    @Test func containerWithRequiredAttribute() {
        let builder = A(href: "/docs") { Span(content: "Docs") }
        let array = A(href: "/docs", children: [Span(content: "Docs")])

        #expect(builder.render() == array.render())
    }

    @Test func containerWithAttributesAndContent() {
        let tag = Div(attributes: [Attribute(key: "id", value: "main")]) {
            P(content: "Hi")
        }

        #expect(tag.render() == "<div id=\"main\"><p>Hi</p></div>")
    }

    @Test func booleanFlagIsPreserved() {
        let tag = Details(open: true) { Summary(content: "More") }

        #expect(tag.render() == "<details open><summary>More</summary></details>")
    }

    @Test func tableFamily() {
        let table = Table {
            Thead { Tr { Th(content: "A") } }
            Tbody { Tr { Td(content: "1") } }
        }

        #expect(table.render() ==
            "<table><thead><tr><th>A</th></tr></thead><tbody><tr><td>1</td></tr></tbody></table>")
    }

    @Test func formFamily() {
        let form = Form {
            Fieldset {
                Legend(content: "Account")
                Label(for: "email", content: "Email")
            }
        }

        #expect(form.render() ==
            "<form><fieldset><legend>Account</legend><label for=\"email\">Email</label></fieldset></form>")
    }

    @Test func mediaFamily() {
        let picture = Picture {
            Source(srcset: "a.webp", type: "image/webp")
            Img(src: "a.jpg", alt: "A")
        }

        #expect(picture.render() ==
            "<picture><source srcset=\"a.webp\" type=\"image/webp\"><img src=\"a.jpg\" alt=\"A\"></picture>")
    }

    @Test func loopsInsideTheBuilder() {
        let list = Ul {
            for name in ["a", "b", "c"] {
                Li(content: name)
            }
        }

        #expect(list.render() == "<ul><li>a</li><li>b</li><li>c</li></ul>")
    }

    @Test func conditionsInsideTheBuilder() {
        let isAdmin = false
        let nav = Nav {
            A(href: "/", content: "Home")
            if isAdmin {
                A(href: "/admin", content: "Admin")
            }
        }

        #expect(nav.render() == "<nav><a href=\"/\">Home</a></nav>")
    }

    @Test func mapInsideTheBuilder() {
        let list = Ol {
            ["x", "y"].map { Li(content: $0) }
        }

        #expect(list.render() == "<ol><li>x</li><li>y</li></ol>")
    }

    @Test func emptyBuilderProducesAnEmptyElement() {
        #expect(Div { }.render() == "<div></div>")
    }

    @Test func untypedElementSupportsTheBuilder() {
        let group = HTMLTag("hgroup") {
            H1(content: "Title")
            P(content: "Subtitle")
        }

        #expect(group.render() == "<hgroup><h1>Title</h1><p>Subtitle</p></hgroup>")
    }

    @Test func chainingStillPreservesTheType() {
        let card: Div = Div { P(content: "Hi") }.addClass("card")

        #expect(card.render() == "<div class=\"card\"><p>Hi</p></div>")
    }

    @Test func nestingIsArbitrarilyDeep() {
        let page = Body {
            MainTag {
                Section {
                    Article {
                        H2(content: "Title")
                    }
                }
            }
        }

        #expect(page.render() ==
            "<body><main><section><article><h2>Title</h2></article></section></main></body>")
    }
}
