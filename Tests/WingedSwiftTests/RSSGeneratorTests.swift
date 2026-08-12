import Foundation
import Testing
@testable import WingedSwift

@Suite struct RSSGeneratorTests {

    private func makeGenerator() -> RSSGenerator {
        RSSGenerator(
            title: "My Blog",
            link: "https://example.com",
            description: "Posts about Swift",
            language: "pt-BR",
            webmaster: "me@example.com"
        )
    }

    @Test func testChannelMetadata() {
        let xml = makeGenerator().generate(items: [])

        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<title>My Blog</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<language>pt-BR</language>"))
        #expect(xml.contains("<webMaster>me@example.com</webMaster>"))
        #expect(xml.hasSuffix("</rss>"))
    }

    @Test func testOptionalChannelFieldsAreOmitted() {
        let xml = RSSGenerator(title: "T", link: "https://e.com", description: "D").generate(items: [])

        #expect(!(xml.contains("<language>")))
        #expect(!(xml.contains("<copyright>")))
        #expect(!(xml.contains("<managingEditor>")))
    }

    @Test func testItemsAreRendered() {
        let item = RSSItem(
            title: "Hello & welcome",
            link: "https://example.com/hello",
            description: "First <post>",
            pubDate: "Tue, 11 Aug 2026 10:00:00 +0000",
            author: "me@example.com",
            categories: ["swift", "html"]
        )

        let xml = makeGenerator().generate(items: [item])

        #expect(xml.contains("<title>Hello &amp; welcome</title>"))
        #expect(xml.contains("<description>First &lt;post&gt;</description>"))
        #expect(xml.contains("<pubDate>Tue, 11 Aug 2026 10:00:00 +0000</pubDate>"))
        #expect(xml.contains("<category>swift</category>"))
        #expect(xml.contains("<category>html</category>"))
    }

    @Test func testGuidDefaultsToTheItemLink() {
        let item = RSSItem(
            title: "T",
            link: "https://example.com/post",
            description: "D",
            pubDate: "Tue, 11 Aug 2026 10:00:00 +0000"
        )

        let xml = makeGenerator().generate(items: [item])

        #expect(xml.contains("<guid isPermaLink=\"true\">https://example.com/post</guid>"))
    }
}
