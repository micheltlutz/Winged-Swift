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
            }
        }
        #expect(div.render(.compact) == "<div><span>modern</span></div>")
        let root = html {
            if #available(macOS 10.15, iOS 13, *) {
                Span(content: "modern")
            }
        }
        #expect(root.render(.compact) == "<html><span>modern</span></html>")
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

    @Test(arguments: [true, false])
    func attributesBuilderSupportsControlFlow(isRequired: Bool) {
        let placeholder: String? = isRequired ? "you@example.com" : nil
        let missing: Attribute? = nil
        let extra = [Attribute(key: "autocomplete", value: "email")]
        let input = HTMLTag("input", attributes: {
            Attribute(key: "name", value: "email")
            if isRequired {
                Attribute.boolean("required")
            } else {
                Attribute(key: "aria-required", value: "false")
            }
            if let placeholder {
                Attribute(key: "placeholder", value: placeholder)
            }
            for key in ["a", "b"] {
                Attribute(key: "data-\(key)", value: key)
            }
            if #available(macOS 10.15, iOS 13, *) {
                extra
            }
            missing
        })
        let expected = isRequired
            ? "<input name=\"email\" required placeholder=\"you@example.com\""
            : "<input name=\"email\" aria-required=\"false\""
        #expect(input.render(.compact)
            == expected + " data-a=\"a\" data-b=\"b\" autocomplete=\"email\">")
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
    private func temporaryDirectory() -> String {
        NSTemporaryDirectory() + "winged-\(UUID().uuidString)"
    }

    /// Runs `body` and returns the error it threw, so the assertions below have no dead branches.
    private func caught(_ body: () throws(WingedError) -> Void) -> WingedError? {
        guard case .failure(let error) = Result(catching: body) else { return nil }
        return error
    }

    @Test func missingAssetThrowsBeforeTouchingTheOutput() {
        let output = temporaryDirectory()
        let generator = StaticSiteGenerator(outputDirectory: output)
        let error = caught { () throws(WingedError) in try generator.copyAsset(from: "/definitely/not/here", to: "x") }
        #expect(error?.description == "Asset not found: /definitely/not/here")
        #expect(!FileManager.default.fileExists(atPath: output))
    }

    @Test func directoryCreationFailureIsWrapped() {
        let generator = StaticSiteGenerator(outputDirectory: "/dev/null/site")
        let error = caught { () throws(WingedError) in try generator.writeFile(content: "x", to: "a.txt") }
        #expect(error?.description.hasPrefix("Could not create directory /dev/null/site") == true)
    }

    @Test func writeFailureIsWrapped() throws {
        let output = temporaryDirectory()
        try FileManager.default.createDirectory(atPath: output + "/index.html", withIntermediateDirectories: true)
        let generator = StaticSiteGenerator(outputDirectory: output)
        let error = caught { () throws(WingedError) in try generator.writeFile(content: "x", to: "index.html") }
        #expect(error?.description.hasPrefix("Could not write \(output)/index.html") == true)
    }

    @Test func copyFailureIsWrapped() throws {
        let output = temporaryDirectory()
        let source = output + "-source.txt"
        try "x".write(toFile: source, atomically: true, encoding: .utf8)
        let tooLong = String(repeating: "n", count: 300)
        let generator = StaticSiteGenerator(outputDirectory: output)
        let error = caught { () throws(WingedError) in try generator.copyAsset(from: source, to: tooLong) }
        #expect(error?.description.hasPrefix("Could not copy \(source)") == true)
    }

    @Test func everyCaseDescribesItself() {
        let underlying = CocoaError(.fileNoSuchFile)
        let cases: [(WingedError, String)] = [
            (.directoryCreationFailed(path: "/a", underlying: underlying), "Could not create directory /a: "),
            (.writeFailed(path: "/b", underlying: underlying), "Could not write /b: "),
            (.copyFailed(source: "/c", destination: "/d", underlying: underlying), "Could not copy /c to /d: "),
            (.removeFailed(path: "/e", underlying: underlying), "Could not remove /e: ")
        ]
        for (error, prefix) in cases {
            #expect(error.description.hasPrefix(prefix))
        }
    }

    @Test func catchClausesCanMatchCases() throws {
        let existing = temporaryDirectory() + ".txt"
        try "x".write(toFile: existing, atomically: true, encoding: .utf8)
        let generator = StaticSiteGenerator(outputDirectory: "/dev/null/site")
        var outcomes: [String] = []
        for source in ["/nope", existing] {
            do {
                try generator.copyAsset(from: source, to: "x")
            } catch .assetNotFound(let path) {
                outcomes.append("missing \(path)")
            } catch {
                outcomes.append("other")
            }
        }
        #expect(outcomes == ["missing /nope", "other"])
    }
}
