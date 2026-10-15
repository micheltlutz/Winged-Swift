import Foundation
import Testing
@testable import WingedSwift

private struct FeatureCard: Component {
    let title: String
    let text: String

    var body: HTMLTag {
        Div {
            H3(content: title)
            P(content: text)
        }
        .addClass("card")
    }
}

private struct Pair: Component {
    var body: HTMLTag {
        Span(content: "a")
        Span(content: "b")
    }
}

@Suite struct ModernBuilderTests {
    @Test func bareStringsBecomeEscapedText() {
        let paragraph = P {
            "Made with "
            Strong(content: "<Winged>")
            " & Swift"
        }
        #expect(paragraph.render(.compact)
            == "<p>Made with <strong>&lt;Winged&gt;</strong> &amp; Swift</p>")
    }

    @Test func stringsWorkInsideHTMLBuilder() {
        let root = html { "Hi" }
        #expect(root.render(.compact) == "<html>Hi</html>")
    }

    @Test func textNodeCanOptOutOfEscaping() {
        #expect(TextNode("<b>x</b>", escape: false).render(.compact) == "<b>x</b>")
    }

    @Test func textNodeIndentsInPrettyMode() {
        let div = Div { "Hello" }
        #expect(div.render(.pretty) == "<div>\n" + RenderOptions.pretty.indent + "Hello\n</div>")
    }

    @Test func optionalTagsRenderOnlyWhenPresent() {
        let present: HTMLTag? = Span(content: "badge")
        let absent: HTMLTag? = nil
        let div = Div {
            present
            absent
        }
        #expect(div.render(.compact) == "<div><span>badge</span></div>")
        #expect(html { absent }.render(.compact) == "<html></html>")
    }

    @Test func availabilityChecksCompileInBuilders() {
        let div = Div {
            if #available(macOS 10.15, iOS 13, *) {
                Span(content: "modern")
            } else {
                Span(content: "legacy")
            }
        }
        #expect(div.render(.compact) == "<div><span>modern</span></div>")
    }

    @Test func componentsRenderInline() {
        let section = Section {
            FeatureCard(title: "Fast", text: "Static HTML.")
            Pair()
        }
        #expect(section.render(.compact)
            == "<section><div class=\"card\"><h3>Fast</h3><p>Static HTML.</p></div>"
            + "<span>a</span><span>b</span></section>")
        #expect(html { Pair() }.render(.compact) == "<html><span>a</span><span>b</span></html>")
    }

    @Test func componentRendersOnItsOwn() {
        #expect(FeatureCard(title: "T", text: "X").render()
            == "<div class=\"card\"><h3>T</h3><p>X</p></div>")
    }

    @Test func attributesBuilderSupportsControlFlow() {
        let isRequired = true
        let placeholder: String? = nil
        let input = HTMLTag("input", attributes: {
            Attribute(key: "name", value: "email")
            if isRequired {
                Attribute.boolean("required")
            }
            if let placeholder {
                Attribute(key: "placeholder", value: placeholder)
            }
            for key in ["a", "b"] {
                Attribute(key: "data-\(key)", value: key)
            }
            Optional<Attribute>.none
        })
        #expect(input.render(.compact)
            == "<input name=\"email\" required data-a=\"a\" data-b=\"b\">")
    }
}

@Suite struct TypedAttributeTests {
    @Test func linkTargetAndRel() {
        let link = A(href: "https://swift.org", content: "Swift")
            .target(.blank)
            .rel([.noopener, .noreferrer, .custom("sponsored")])
        #expect(link.render(.compact)
            == "<a href=\"https://swift.org\" target=\"_blank\" rel=\"noopener noreferrer sponsored\">Swift</a>")
    }

    @Test func modifiersReplaceExistingValues() {
        let img = Img(src: "a.png", alt: "A")
            .loading(.eager)
            .loading(.lazy)
            .decoding(.async)
        let rendered = img.render(.compact)
        #expect(rendered.contains("loading=\"lazy\""))
        #expect(!rendered.contains("eager"))
        #expect(rendered.contains("decoding=\"async\""))
    }

    @Test func hiddenTabIndexAndLang() {
        let div = Div().hidden().tabIndex(-1).lang("pt-BR")
        #expect(div.render(.compact) == "<div hidden tabindex=\"-1\" lang=\"pt-BR\"></div>")
        #expect(Div().hidden().hidden(false).render(.compact) == "<div></div>")
    }

    @Test func chainingKeepsTheConcreteType() {
        let link: A = A(href: "/", content: "Home").target(.current)
        #expect(link.render(.compact).contains("target=\"_self\""))
    }
}

@Suite struct WingedErrorTests {
    @Test func missingAssetThrowsATypedError() {
        let generator = StaticSiteGenerator(outputDirectory: NSTemporaryDirectory() + "winged-\(UUID())")
        do {
            try generator.copyAsset(from: "/definitely/not/here", to: "x")
            Issue.record("expected an error")
        } catch {
            guard case .assetNotFound(let path) = error else {
                Issue.record("unexpected error \(error)")
                return
            }
            #expect(path == "/definitely/not/here")
            #expect(error.description == "Asset not found: /definitely/not/here")
        }
    }
}

@Suite struct WingedErrorPatternTests {
    @Test func catchClausesCanMatchCases() {
        let generator = StaticSiteGenerator(outputDirectory: NSTemporaryDirectory() + "winged-\(UUID())")
        var missing: String?
        do {
            try generator.copyAsset(from: "/nope", to: "x")
        } catch .assetNotFound(let path) {
            missing = path
        } catch {
            Issue.record("unexpected error \(error)")
        }
        #expect(missing == "/nope")
    }
}
