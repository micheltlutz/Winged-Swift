import Foundation
import Testing
@testable import WingedSwift

/// Full pages frozen as files, so an accidental change to whitespace, escaping or attribute order
/// shows up as a diff instead of passing unnoticed.
///
/// Regenerate after an intentional change:
///
///     WINGED_UPDATE_FIXTURES=1 swift test --filter GoldenFileTests
@Suite struct GoldenFileTests {

    // MARK: - Fixtures

    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
    }

    private func assertMatchesFixture(_ rendered: String, named name: String) throws {
        let url = Self.fixturesDirectory.appendingPathComponent(name)
        let shouldUpdate = ProcessInfo.processInfo.environment["WINGED_UPDATE_FIXTURES"] == "1"

        guard FileManager.default.fileExists(atPath: url.path), !shouldUpdate else {
            try FileManager.default.createDirectory(at: Self.fixturesDirectory,
                                                    withIntermediateDirectories: true)
            try rendered.write(to: url, atomically: true, encoding: .utf8)
            Issue.record("Wrote fixture \(name) — re-run the tests to compare against it.")
            return
        }

        let expected = try String(contentsOf: url, encoding: .utf8)
        #expect(rendered == expected, "\(name) differs. Run WINGED_UPDATE_FIXTURES=1 swift test if the change is intentional.")
    }

    // MARK: - The page under test

    private func marketingPage() -> Document {
        Document(lang: "pt-BR") {
            Fragment(children: SEO.complete(
                title: "RideKeeper",
                description: "Motorcycle maintenance companion",
                image: "https://ridekeeper.example/og.jpg",
                url: "https://ridekeeper.example",
                keywords: ["swift", "motorcycle"],
                author: "Michel Lutz",
                twitterSite: "@micheltlutz"
            ))
            Title(content: "RideKeeper — track every service")
            Link(href: "/css/style.css", rel: "stylesheet")
        } body: {
            Header {
                Nav {
                    A(href: "/", content: "RideKeeper").addClass("logo")
                    Ul {
                        for item in [("/", "Home"), ("/pricing", "Pricing & plans")] {
                            Li { A(href: item.0, content: item.1) }
                        }
                    }
                }
            }

            MainTag {
                Section(attributes: [Attribute(key: "id", value: "hero")]) {
                    H1(content: "Track every service")
                    P(content: "Fuel, tyres & chain — all in one place.")
                    A(href: "https://apps.example/app", content: "Download").addClass("button")
                }

                Table {
                    Caption(content: "Plans")
                    Thead { Tr { Th(content: "Plan"); Th(content: "Price") } }
                    Tbody {
                        Tr { Td(content: "Free"); Td(content: "R$ 0") }
                        Tr { Td(content: "Pro"); Td(content: "R$ 9,90/mês") }
                    }
                }

                Details(open: true) {
                    Summary(content: "Is my data private?")
                    P(content: "Yes — everything syncs through your own iCloud account.")
                }

                Form(attributes: [Attribute(key: "action", value: "/subscribe")]) {
                    Fieldset {
                        Legend(content: "Newsletter")
                        Label(for: "email", content: "E-mail")
                        Input(type: "email", name: "email", attributes: [.boolean("required")])
                        Button(type: "submit", content: "Subscribe")
                    }
                }

                Pre { Code(content: "let page = html { }") }

                Figure {
                    Img(src: "/img/app.png", alt: "App screenshot")
                    Figcaption(content: "The garage screen")
                }
            }

            Footer {
                P(content: "© 2026 RideKeeper — built with Swift & WingedSwift")
            }
        }
    }

    // MARK: - Tests

    @Test func prettyDocumentMatchesFixture() throws {
        try assertMatchesFixture(marketingPage().render(.pretty), named: "marketing-pretty.html")
    }

    @Test func compactDocumentMatchesFixture() throws {
        try assertMatchesFixture(marketingPage().render(.compact), named: "marketing-compact.html")
    }

    @Test func feedsMatchFixtures() throws {
        let sitemap = SitemapGenerator.generate(urls: [
            SitemapURL(loc: "https://ridekeeper.example/", changefreq: "weekly", priority: 1.0),
            SitemapURL(loc: "https://ridekeeper.example/pricing?plan=pro&billing=year",
                       lastmod: "2026-08-11", changefreq: "monthly", priority: 0.7)
        ])
        try assertMatchesFixture(sitemap, named: "sitemap.xml")

        let feed = RSSGenerator(
            title: "RideKeeper",
            link: "https://ridekeeper.example",
            description: "Release notes",
            language: "pt-BR"
        ).generate(items: [
            RSSItem(title: "1.2 — tyres & chain",
                    link: "https://ridekeeper.example/blog/1-2",
                    description: "Tyre pressure log <and> chain reminders",
                    pubDate: "Tue, 11 Aug 2026 10:00:00 +0000",
                    categories: ["release"])
        ])
        try assertMatchesFixture(feed, named: "feed.xml")
    }
}
