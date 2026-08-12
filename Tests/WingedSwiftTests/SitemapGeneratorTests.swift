import Foundation
import Testing
@testable import WingedSwift

@Suite struct SitemapGeneratorTests {

    @Test func testGenerateProducesValidURLSet() {
        let xml = SitemapGenerator.generate(urls: [
            SitemapURL(loc: "https://example.com/", changefreq: "daily", priority: 1.0),
            SitemapURL(loc: "https://example.com/about", lastmod: "2026-08-11")
        ])

        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"))
        #expect(xml.contains("<loc>https://example.com/</loc>"))
        #expect(xml.contains("<changefreq>daily</changefreq>"))
        #expect(xml.contains("<lastmod>2026-08-11</lastmod>"))
        #expect(xml.hasSuffix("</urlset>\n") || xml.hasSuffix("</urlset>"))
    }

    @Test func testGenerateEscapesAmpersandsInURLs() {
        let xml = SitemapGenerator.generate(urls: [
            SitemapURL(loc: "https://example.com/search?q=a&page=2")
        ])

        #expect(xml.contains("q=a&amp;page=2"))
        #expect(!(xml.contains("q=a&page=2")))
    }

    @Test func testOptionalFieldsAreOmitted() {
        let xml = SitemapGenerator.generate(urls: [SitemapURL(loc: "https://example.com/")])

        #expect(!(xml.contains("<lastmod>")))
        #expect(!(xml.contains("<changefreq>")))
        #expect(!(xml.contains("<priority>")))
    }

    @Test func testPriorityIsRenderedWithOneDecimal() {
        let xml = SitemapGenerator.generate(urls: [
            SitemapURL(loc: "https://example.com/", priority: 0.5)
        ])

        #expect(xml.contains("<priority>0.5</priority>"))
    }

    @Test func testGeneratesASitemapIndex() {
        let xml = SitemapGenerator.generateIndex(sitemaps: [
            (loc: "https://example.com/sitemap-posts.xml", lastmod: "2026-08-11"),
            (loc: "https://example.com/sitemap-pages.xml?v=2&full=1", lastmod: nil)
        ])

        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<sitemapindex"))
        #expect(xml.contains("<loc>https://example.com/sitemap-posts.xml</loc>"))
        #expect(xml.contains("<lastmod>2026-08-11</lastmod>"))
        #expect(xml.contains("v=2&amp;full=1"))
        #expect(xml.contains("</sitemapindex>"))
    }

    @Test func testSitemapIndexOmitsAMissingLastmod() {
        let xml = SitemapGenerator.generateIndex(sitemaps: [
            (loc: "https://example.com/sitemap.xml", lastmod: nil)
        ])

        #expect(!xml.contains("<lastmod>"))
    }

    @Test func testEmptyURLListStillProducesAWellFormedDocument() {
        let xml = SitemapGenerator.generate(urls: [])

        #expect(xml.contains("<urlset"))
        #expect(xml.contains("</urlset>"))
        #expect(!(xml.contains("<url>")))
    }
}
