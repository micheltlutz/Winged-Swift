import Foundation
import Testing
@testable import WingedSwift

@Suite struct FragmentTests {

    @Test func testFragmentRendersChildrenWithoutWrapper() {
        let group = Fragment(children: [Li(content: "a"), Li(content: "b")])

        #expect(group.render() == "<li>a</li><li>b</li>")
    }

    @Test func testEmptyFragmentRendersNothing() {
        #expect(Fragment().render() == "")
        #expect(Fragment().render(.pretty) == "")
    }

    @Test func testFragmentKeepsPrettyIndentation() {
        let list = Ul(children: [
            fragment {
                Li(content: "a")
                Li(content: "b")
            }
        ])

        #expect(list.render(.pretty) == """
            <ul>
              <li>a</li>
              <li>b</li>
            </ul>
            """)
    }

    @Test func testFragmentBuilderSupportsMapAndFilter() {
        let names = ["Ana", "Bruno", "Carla"]
        let group = fragment {
            names.filter { $0.count > 3 }.map { Li(content: $0) }
        }

        #expect(group.render() == "<li>Bruno</li><li>Carla</li>")
    }

    @Test func testEmptyFragmentDoesNotLeaveBlankLines() {
        let container = Div(children: [P(content: "one"), Fragment(), P(content: "two")])

        #expect(container.render(.pretty) == """
            <div>
              <p>one</p>
              <p>two</p>
            </div>
            """)
    }

    @Test func testFalseConditionDoesNotEmitStrayHTMLNode() {
        let showBanner = false
        let page = html {
            Head(children: [Title(content: "Home")])
            if showBanner {
                Div(content: "banner")
            }
            Body(children: [H1(content: "Hi")])
        }

        let rendered = page.render()

        #expect(rendered == "<html><head><title>Home</title></head><body><h1>Hi</h1></body></html>")
    }

    @Test func testTrueConditionEmitsTheBranch() {
        let showBanner = true
        let page = html {
            if showBanner {
                Div(content: "banner")
            }
        }

        #expect(page.render() == "<html><div>banner</div></html>")
    }

    @Test func testLoopInsideHTMLBuilder() {
        let page = html {
            for index in 1...3 {
                P(content: "line \(index)")
            }
        }

        #expect(page.render() == "<html><p>line 1</p><p>line 2</p><p>line 3</p></html>")
    }

    @Test func testRawHTMLStillEmitsMarkupVerbatim() {
        let raw = RawHTML("<custom-element data-x=\"1\"></custom-element>")

        #expect(raw.render() == "<custom-element data-x=\"1\"></custom-element>")
    }
}
