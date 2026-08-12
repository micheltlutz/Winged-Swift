import Foundation
import Testing
@testable import WingedSwift

@Suite struct RenderOptionsTests {

    @Test func compactIsTheDefault() {
        let div = Div(children: [P(content: "Hi")])

        #expect(div.render() == div.render(.compact))
        #expect(div.render() == "<div><p>Hi</p></div>")
    }

    @Test func prettyIndentsChildren() {
        let div = Div(children: [P(content: "Hi")])

        #expect(div.render(.pretty) == """
            <div>
              <p>Hi</p>
            </div>
            """)
    }

    @Test func indentIsConfigurable() {
        let div = Div(children: [P(content: "Hi")])
        let options = RenderOptions(pretty: true, indent: "    ")

        #expect(div.render(options) == """
            <div>
                <p>Hi</p>
            </div>
            """)
    }

    @Test func xhtmlSelfClosingIsPerCall() {
        let img = Img(src: "a.png")

        #expect(img.render(.compact) == "<img src=\"a.png\">")
        #expect(img.render(RenderOptions(xhtmlSelfClosing: true)) == "<img src=\"a.png\" />")
        // The option is a value, so the previous call cannot have changed anything.
        #expect(img.render(.compact) == "<img src=\"a.png\">")
    }

    @Test func optionsAreValues() {
        var options = RenderOptions.pretty
        options.indent = "\t"

        #expect(RenderOptions.pretty.indent == "  ")
        #expect(options.pretty)
        #expect(options != RenderOptions.pretty)
    }

    @Test func writeAppendsToAnExistingBuffer() {
        var buffer = "<!-- header -->"
        Div(content: "x").write(into: &buffer, options: .compact)

        #expect(buffer == "<!-- header --><div>x</div>")
    }

    /// Two renders with different options must not interfere, even concurrently.
    @Test func concurrentRendersDoNotShareState() async {
        let results = await withTaskGroup(of: String.self) { group -> [String] in
            for index in 0..<8 {
                group.addTask {
                    let tag = Img(src: "\(index).png")
                    let options = RenderOptions(xhtmlSelfClosing: index.isMultiple(of: 2))
                    return tag.render(options)
                }
            }
            var collected: [String] = []
            for await result in group { collected.append(result) }
            return collected
        }

        for result in results {
            let isXHTML = result.hasSuffix(" />")
            let index = Int(result.split(separator: "\"")[1].split(separator: ".")[0])!
            #expect(isXHTML == index.isMultiple(of: 2))
        }
    }
}
