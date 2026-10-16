import Foundation
import Testing
@testable import WingedSwift

@Suite struct URLPolicyTests {
    @Test(arguments: ["javascript:alert(1)", "JaVaScRiPt:alert(1)", " javascript:x", "java\tscript:x",
                      "java\nscript:x", "\u{0001}javascript:x", "vbscript:msgbox", "data:text/html,<b>x</b>"])
    func scriptURLsAreNeutralised(url: String) {
        #expect(A(href: url, content: "x").render() == "<a href=\"#\">x</a>")
    }

    @Test func otherURLsAndAttributesAreUntouched() {
        #expect(A(href: "https://swift.org/javascript:", content: "x").render() == "<a href=\"https://swift.org/javascript:\">x</a>")
        #expect(Img(src: "data:image/png;base64,AAA", alt: "").render().contains("src=\"data:image/png;base64,AAA\""))
        #expect(Div().setAttribute(key: "title", value: "javascript:fine").render() == "<div title=\"javascript:fine\"></div>")
        #expect(HTMLTag("form", attributes: [Attribute(key: "ACTION", value: "javascript:x")]).render() == "<form ACTION=\"#\"></form>")
        #expect(HTMLTag("button", attributes: [.boolean("formaction")]).render() == "<button formaction></button>")
    }

    @Test func trustedURLsRenderAsGiven() {
        #expect(A(href: "#", content: "Print").trustedURL("href", "javascript:print()").render()
            == "<a href=\"javascript:print()\">Print</a>")
        #expect(HTMLTag("a", attributes: [.trustedURL(key: "href", value: "javascript:x")]).render()
            == "<a href=\"javascript:x\"></a>")
    }

    @Test func markdownLinksAreCovered() {
        let html = Fragment(children: Markdown.parse("[click](javascript:alert(document.cookie))")).render()
        #expect(html == "<p><a href=\"#\">click</a>)</p>" || html == "<p><a href=\"#\">click</a></p>")
    }
}

@Suite struct StreamingWriteTests {
    private func temporaryFile() -> String {
        NSTemporaryDirectory() + "winged-stream-\(UUID().uuidString).html"
    }

    private func page(sections: Int, empty: Bool = false) -> Document {
        Document(lang: "en") {
            Title(content: "Streaming")
            Meta(charset: "UTF-8")
        } body: {
            if empty { Fragment() }
            for index in 0..<sections {
                Section {
                    H2(content: "Section \(index)")
                    P(content: String(repeating: "text & more ", count: 50))
                    Img(src: "/\(index).png", alt: "")
                }
                .addClass("s")
            }
            if empty { Fragment() }
        }
    }

    @Test(arguments: [RenderOptions.pretty, .compact, RenderOptions(pretty: true, indent: "\t", xhtmlSelfClosing: true)])
    func fileMatchesRender(options: RenderOptions) throws {
        for document in [page(sections: 3), page(sections: 400), page(sections: 2, empty: true)] {
            let path = temporaryFile()
            try document.write(toFile: path, options: options)
            #expect(try String(contentsOfFile: path, encoding: .utf8) == document.render(options))
        }
    }

    @Test func bodiesThatCannotStreamStillMatch() throws {
        let documents = [
            Document(lang: nil, head: Head(), body: Body()),
            Document(lang: "en", head: Head(), body: Body(content: "<raw>"))
        ]
        for document in documents {
            for options in [RenderOptions.pretty, .compact] {
                let path = temporaryFile()
                try document.write(toFile: path, options: options)
                #expect(try String(contentsOfFile: path, encoding: .utf8) == document.render(options))
            }
        }
    }

    @Test func replacesAnExistingFileAndReportsFailures() throws {
        let path = temporaryFile()
        try "old".write(toFile: path, atomically: true, encoding: .utf8)
        try page(sections: 1).write(toFile: path)
        #expect(try String(contentsOfFile: path, encoding: .utf8).hasPrefix("<!DOCTYPE html>"))
        #expect(!FileManager.default.fileExists(atPath: path + ".winged-tmp"))

        var caught: WingedError?
        do {
            try page(sections: 1).write(toFile: "/definitely/missing/dir/page.html")
        } catch {
            caught = error
        }
        #expect(caught?.description.hasPrefix("Could not write /definitely/missing/dir/page.html") == true)
    }

    @Test func generatorStreamsDocuments() throws {
        let output = NSTemporaryDirectory() + "winged-stream-site-\(UUID().uuidString)"
        let document = page(sections: 5)
        try StaticSiteGenerator(outputDirectory: output).generate(document: document, to: "a/b/index.html")
        let written = try String(contentsOfFile: output + "/a/b/index.html", encoding: .utf8)
        #expect(written == document.render(.pretty))
    }
}

@Suite struct VersionTests {
    @Test func versionMetadata() {
        #expect(WingedSwiftVersion.current.split(separator: ".").count == 3)
        #expect(WingedSwiftVersion.author.isEmpty == false)
        #expect(WingedSwiftVersion.contact.hasPrefix("https://"))
    }

    @Test func renderDefaultsToCompact() {
        let div = Div { P(content: "x") }
        #expect(div.render() == div.render(.compact))
    }
}

@Suite struct CopyTests {
    @Test func copiesAreIndependent() {
        let card = Div { P(content: "Card") }.addClass("card")
        let highlighted = card.copy().addClass("highlight")
        #expect(card.render() == "<div class=\"card\"><p>Card</p></div>")
        #expect(highlighted.render() == "<div class=\"card highlight\"><p>Card</p></div>")
        highlighted.children.first?.addChild(Span(content: "new"))
        #expect(card.render() == "<div class=\"card\"><p>Card</p></div>")
    }

    @Test func specialNodesKeepTheirRendering() {
        let tree = Div {
            "text & more"
            RawHTML("<svg></svg>")
            Fragment { Em(content: "a"); Em(content: "b") }
            P { "inline "; Strong(content: "x") }.inline()
            Pre(children: [Code(content: "keep\n" + String(repeating: " ", count: 2) + "spaces")])
        }
        for options in [RenderOptions.compact, .pretty] {
            #expect(tree.copy().render(options) == tree.render(options))
        }
        let markdown = Fragment(children: Markdown.parse("Hello *you*\n\n- a"))
        #expect(markdown.copy().render(.pretty) == markdown.render(.pretty))
    }
}
