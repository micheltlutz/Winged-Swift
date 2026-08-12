import Foundation
import Testing
@testable import WingedSwift

/// `Layout` is the 1.x way to share a page shell — still supported alongside `Document`.
@Suite struct LayoutTests {

    private struct BlogLayout: Layout {
        let siteTitle: String

        func render(content: HTMLTag) -> HTMLTag {
            html {
                Head(children: [Title(content: siteTitle)])
                Body(children: [
                    Header(children: [H1(content: siteTitle)]),
                    content,
                    Footer(content: "© 2026")
                ])
            }
        }
    }

    @Test func wrapsASingleTag() {
        let page = BlogLayout(siteTitle: "My Blog").render(content: MainTag(content: "Post"))

        #expect(page.render() ==
            "<html><head><title>My Blog</title></head>"
            + "<body><header><h1>My Blog</h1></header><main>Post</main><footer>© 2026</footer></body></html>")
    }

    @Test func wrapsSeveralTagsInAContainer() {
        let page = BlogLayout(siteTitle: "My Blog").render(contents: [
            Article(content: "First"),
            Article(content: "Second")
        ])

        #expect(page.render().contains("<div><article>First</article><article>Second</article></div>"))
    }

    @Test func anEmptyContentListStillProducesAPage() {
        let page = BlogLayout(siteTitle: "My Blog").render(contents: [])

        #expect(page.render().contains("<div></div>"))
        #expect(page.render().contains("<h1>My Blog</h1>"))
    }
}
