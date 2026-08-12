import Foundation
import Testing
@testable import WingedSwift

@Suite struct DocumentTests {

    @Test func rendersDoctypeAndLanguage() {
        let page = Document(lang: "pt-BR") {
            Title(content: "Início")
        } body: {
            H1(content: "Olá")
        }

        #expect(page.render(.compact) ==
            "<!DOCTYPE html>\n<html lang=\"pt-BR\"><head><title>Início</title></head>"
            + "<body><h1>Olá</h1></body></html>")
    }

    @Test func languageIsOptional() {
        let page = Document {
            Title(content: "T")
        } body: {
            P(content: "B")
        }

        #expect(page.render(.compact).contains("<html><head>"))
    }

    @Test func prettyIsTheDefaultForDocuments() {
        let page = Document { Title(content: "T") } body: { H1(content: "H") }

        #expect(page.render() == """
            <!DOCTYPE html>
            <html>
              <head>
                <title>T</title>
              </head>
              <body>
                <h1>H</h1>
              </body>
            </html>
            """)
    }

    @Test func acceptsAnExistingHeadAndBody() {
        let page = Document(
            lang: "en",
            head: Head(children: [Title(content: "T")]),
            body: Body(children: [P(content: "B")])
        )

        #expect(page.render(.compact).contains("<title>T</title>"))
        #expect(page.render(.compact).contains("<p>B</p>"))
    }

    @Test func rootExposesTheHTMLElementWithoutTheDoctype() {
        let page = Document(lang: "en") { Title(content: "T") } body: { P(content: "B") }

        let root = page.root()

        #expect(!root.render(.compact).contains("<!DOCTYPE"))
        #expect(root.render(.compact).hasPrefix("<html lang=\"en\">"))
    }

    @Test func buildersSupportLoopsAndConditions() {
        let showBanner = false
        let page = Document {
            Title(content: "T")
        } body: {
            if showBanner {
                Div(content: "banner")
            }
            for index in 1...2 {
                P(content: "line \(index)")
            }
        }

        let rendered = page.render(.compact)
        #expect(!rendered.contains("banner"))
        #expect(rendered.contains("<p>line 1</p><p>line 2</p>"))
    }

    @Test func documentIsAValue() {
        let original = Document(lang: "en") { Title(content: "T") } body: { P(content: "B") }
        var copy = original
        copy.lang = "pt-BR"

        #expect(original.lang == "en")
        #expect(copy.lang == "pt-BR")
    }
}
