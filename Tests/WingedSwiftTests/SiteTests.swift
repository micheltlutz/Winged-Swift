import Foundation
import Testing
@testable import WingedSwift

// MARK: - A small site under test

private struct SiteFooter: Component {
    @Environment(\.site) var site
    @Environment(\.page) var page

    var body: HTMLTag {
        Footer { P(content: "© \(site.name) — \(page.path)") }
    }
}

private struct Navigation: Component {
    @Environment(\.pages) var pages

    var body: HTMLTag {
        Nav {
            for page in pages where page.path != "/404.html" {
                A(href: page.path, content: page.title)
            }
        }
    }
}

private struct MainLayout: PageLayout {
    func head() -> [HTMLTag] {
        Link(href: "/css/style.css", rel: "stylesheet")
    }

    func body(content: HTMLTag) -> [HTMLTag] {
        Navigation()
        MainTag(children: [content])
        SiteFooter()
    }
}

private struct BareLayout: PageLayout {
    func body(content: HTMLTag) -> [HTMLTag] {
        content
    }
}

private struct Home: Page {
    var title = "Home"
    var body: HTMLTag { H1(content: "Welcome") }
}

private struct AboutPage: Page {
    var title = "About"
    var description = "Who we are"
    var image = "/img/about.png"
    var body: HTMLTag { H1(content: "About & us") }
}

private struct Pricing: Page {
    var title = "Pricing"
    var path = "pricing"
    var body: HTMLTag { P(content: "Free") }
}

private struct Drafts: Page {
    var title = "Drafts"
    var isInSitemap = false
    var body: HTMLTag { P(content: "Not listed") }
}

private struct Raw: Page {
    var title = "Raw"
    var path = "/raw.html"
    var body: HTMLTag { P(content: "raw") }
}

private struct CustomNotFound: Page {
    var title = "Lost"
    var path = "/404.html"
    var body: HTMLTag { H1(content: "Lost") }
}

private struct DemoSite: Site {
    var name = "Demo"
    var url = "https://demo.example/"
    var language = "pt-BR"
    var description = "A demo site"
    var author = "Michel"
    var twitterSite = "@demo"
    var homePage = Home()
    var layout = MainLayout()
    var includeDrafts = true
    var feedItems: [FeedItem] = []
    var assetsDirectory = "assets"

    var pages: [any Page] {
        AboutPage()
        Pricing()
        if includeDrafts {
            Drafts()
        } else {
            Raw()
        }
        [Raw()].filter { _ in includeDrafts }
    }

    func layout(for page: any Page) -> any PageLayout {
        page is Raw ? BareLayout() : layout
    }
}

private struct MinimalSite: Site {
    var name = "Minimal"
    var url = "https://minimal.example"
    var homePage = Home()
    var layout = EmptyLayout()
    var errorPage = CustomNotFound()
}

private struct DuplicateSite: Site {
    var name = "Dup"
    var url = "https://dup.example"
    var homePage = Home()
    var layout = EmptyLayout()
    var pages: [any Page] {
        Pricing()
        Pricing()
    }
}

// MARK: - Helpers

private func temporaryPackage() throws -> URL {
    let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("winged-site-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: root.appendingPathComponent("Sources/Demo"), withIntermediateDirectories: true)
    try "// swift-tools-version: 6.0".write(to: root.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
    return root
}

private func read(_ url: URL, _ path: String) throws -> String {
    try String(contentsOf: url.appendingPathComponent(path), encoding: .utf8)
}

private let fixtures = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Fixtures")

// MARK: - Tests

@Suite struct PageTests {
    @Test func slugsComeFromTheTypeName() {
        #expect(AboutPage().path == "/about/")
        #expect(Home().path == "/home/")
        #expect(Home.slug("ContactUsPage") == "contact-us")
        #expect(Home.slug("Page") == "page")
        #expect(Home.slug("FAQ2024Notes") == "faq2024-notes")
        #expect(Home.slug("Hello_World") == "hello-world")
    }

    @Test func pathsAreNormalised() {
        #expect(DemoSite.normalize("about") == "/about/")
        #expect(DemoSite.normalize("/about/") == "/about/")
        #expect(DemoSite.normalize("/") == "/")
        #expect(DemoSite.normalize("feed.html") == "/feed.html")
        #expect(DemoSite.filePath(for: "/") == "index.html")
        #expect(DemoSite.filePath(for: "/blog/post/") == "blog/post/index.html")
        #expect(DemoSite.filePath(for: "/404.html") == "404.html")
    }

    @Test func defaultsAreEmpty() {
        #expect(Home().description.isEmpty)
        #expect(Home().image.isEmpty)
        #expect(Home().isInSitemap)
        #expect(EmptyLayout().head().isEmpty)
    }

    @Test func pageBuilderSupportsControlFlow() {
        #expect(DemoSite().pages.map(\.title) == ["About", "Pricing", "Drafts", "Raw"])
        #expect(DemoSite(includeDrafts: false).pages.map(\.title) == ["About", "Pricing", "Raw"])
        #expect(MinimalSite().pages.isEmpty)
        let pages = PageBuilder.buildLimitedAvailability(PageBuilder.buildArray([[Home()], [AboutPage()]]))
        #expect(pages.map(\.title) == ["Home", "About"])
        #expect(PageBuilder.buildOptional(nil).isEmpty)
    }
}

@Suite struct SiteRenderingTests {
    @Test func aboutPageMatchesTheFixture() throws {
        let rendered = try #require(try DemoSite().document(at: "/about/")).render(.pretty)
        let url = fixtures.appendingPathComponent("site-about.html")
        if ProcessInfo.processInfo.environment["WINGED_UPDATE_FIXTURES"] == "1" { try rendered.write(to: url, atomically: true, encoding: .utf8) }
        let expected = try String(contentsOf: url, encoding: .utf8)
        #expect(rendered == expected)
    }

    @Test func homeUsesTheSiteNameAsTitle() throws {
        let html = try #require(try DemoSite().document(at: "/")).render(.compact)
        #expect(html.contains("<title>Demo</title>"))
        #expect(html.contains("<meta property=\"og:type\" content=\"website\">"))
        #expect(html.contains("<meta name=\"description\" content=\"A demo site\">"))
        #expect(!html.contains("og:image"))
        #expect(html.contains("<meta name=\"twitter:card\" content=\"summary\">"))
        #expect(html.contains("<footer><p>© Demo — /</p></footer>"))
        #expect(html.hasPrefix("<!DOCTYPE html>\n<html lang=\"pt-BR\">"))
    }

    @Test func pagesGetCanonicalAndSocialTags() throws {
        let html = try #require(try DemoSite().document(at: "about")).render(.compact)
        #expect(html.contains("<title>About — Demo</title>"))
        #expect(html.contains("<link href=\"https://demo.example/about/\" rel=\"canonical\">"))
        #expect(html.contains("<meta property=\"og:image\" content=\"https://demo.example/img/about.png\">"))
        #expect(html.contains("<meta name=\"twitter:card\" content=\"summary_large_image\">"))
        #expect(html.contains("<meta name=\"twitter:site\" content=\"@demo\">"))
        #expect(html.contains("<h1>About &amp; us</h1>"))
    }

    @Test func aPageCanChooseItsOwnLayout() throws {
        let html = try #require(try DemoSite().document(at: "/raw.html")).render(.compact)
        #expect(html.contains("<body><p>raw</p></body>"))
    }

    @Test func minimalSiteOmitsOptionalTags() throws {
        let html = try #require(try MinimalSite().document(at: "/")).render(.compact)
        #expect(!html.contains("name=\"description\""))
        #expect(!html.contains("name=\"author\""))
        #expect(!html.contains("twitter:site"))
        #expect(html.contains("<html lang=\"en\">"))
        let missing = try #require(try MinimalSite().document(at: "/404.html")).render(.compact)
        #expect(missing.contains("<title>Lost — Minimal</title>"))
        #expect(!missing.contains("rel=\"canonical\""))
        let nothing = try MinimalSite().document(at: "/nope/")
        #expect(nothing == nil)
    }

    @Test func defaultNotFoundPage() throws {
        let html = try #require(try DemoSite().document(at: "/404.html")).render(.compact)
        #expect(html.contains("<h1>Page not found</h1>"))
        #expect(html.contains("<p>The page you are looking for does not exist. <a href=\"/\">Go to the home page</a>.</p>"))
    }

    @Test func feedLinkAppearsWhenThereAreItems() throws {
        var site = DemoSite()
        site.feedItems = [FeedItem(title: "Post", link: "/post/", summary: "S", date: Date(timeIntervalSince1970: 0))]
        let html = try #require(try site.document(at: "/")).render(.compact)
        #expect(html.contains("<link href=\"/feed.xml\" rel=\"alternate\" type=\"application/rss+xml\" title=\"Demo\">"))
    }

    @Test func environmentOutsidePublishHasDefaults() {
        #expect(SiteFooter().render() == "<footer><p>© " + " — /</p></footer>")
        let values = EnvironmentValues(site: SiteMetadata(name: "Scripted", url: "https://s.example/"),
                                       page: PageMetadata(title: "T", path: "/t/"))
        let html = EnvironmentValues.withValues(values) { SiteFooter().render() }
        #expect(html == "<footer><p>© Scripted — /t/</p></footer>")
        #expect(values.site.url == "https://s.example")
    }

    @Test func environmentNestsAndIsPerThread() async {
        let outer = EnvironmentValues(site: SiteMetadata(name: "Outer"))
        let inner = EnvironmentValues(site: SiteMetadata(name: "Inner"))
        let names = EnvironmentValues.withValues(outer) {
            let nested = EnvironmentValues.withValues(inner) { EnvironmentValues.current.site.name }
            return [nested, EnvironmentValues.current.site.name]
        }
        #expect(names == ["Inner", "Outer"])
        #expect(EnvironmentValues.current.site.name.isEmpty)

        let rendered = await withTaskGroup(of: String.self) { group in
            for name in ["A", "B", "C", "D"] {
                group.addTask {
                    EnvironmentValues.withValues(EnvironmentValues(site: SiteMetadata(name: name))) {
                        Thread.sleep(forTimeInterval: 0.01)
                        return EnvironmentValues.current.site.name
                    }
                }
            }
            return await group.reduce(into: []) { $0.append($1) }.sorted()
        }
        #expect(rendered == ["A", "B", "C", "D"])
    }
}

@Suite struct SitePublishTests {
    @Test func publishWritesTheWholeSite() throws {
        let root = try temporaryPackage()
        try FileManager.default.createDirectory(at: root.appendingPathComponent("assets/css"), withIntermediateDirectories: true)
        try "body{}".write(to: root.appendingPathComponent("assets/css/style.css"), atomically: true, encoding: .utf8)
        try "x".write(to: root.appendingPathComponent("assets/.DS_Store"), atomically: true, encoding: .utf8)

        let report = try DemoSite().publish(to: "out", from: "\(root.path)/Sources/Demo/main.swift")
        let out = root.appendingPathComponent("out")
        #expect(report.outputDirectory == out.path)
        #expect(report.files == ["index.html", "about/index.html", "pricing/index.html", "drafts/index.html",
                                 "raw.html", "404.html", "sitemap.xml", "robots.txt"])
        #expect(try read(out, "css/style.css") == "body{}")
        #expect(!FileManager.default.fileExists(atPath: out.appendingPathComponent(".DS_Store").path))
        #expect(try read(out, "index.html").hasPrefix("<!DOCTYPE html>\n<html lang=\"pt-BR\">\n" + RenderOptions.pretty.indent + "<head>"))

        let sitemap = try read(out, "sitemap.xml")
        #expect(sitemap.contains("<loc>https://demo.example/</loc>"))
        #expect(sitemap.contains("<loc>https://demo.example/pricing/</loc>"))
        #expect(!sitemap.contains("drafts"))
        #expect(!sitemap.contains("404"))
        #expect(try read(out, "robots.txt") == "User-agent: *\nAllow: /\n\nSitemap: https://demo.example/sitemap.xml\n")
    }

    @Test func publishWritesTheFeedInTheChosenFormat() throws {
        let root = try temporaryPackage()
        try MinimalSite().publish(to: root.appendingPathComponent("plain").path, from: "\(root.path)/Package.swift")
        #expect(!FileManager.default.fileExists(atPath: root.appendingPathComponent("plain/feed.xml").path))

        var demo = DemoSite()
        demo.feedItems = [FeedItem(title: "Post", link: "/post/", summary: "S", date: Date(timeIntervalSince1970: 0))]
        demo.assetsDirectory = "missing"
        let report = try demo.publish(to: root.appendingPathComponent("feed").path, from: "\(root.path)/Package.swift")
        #expect(report.files.last == "feed.xml")
        #expect(try read(root.appendingPathComponent("feed"), "feed.xml").contains("<link>https://demo.example/post/</link>"))
    }

    @Test func duplicatePathsAreRejected() throws {
        let root = try temporaryPackage()
        var caught: WingedError?
        do {
            try DuplicateSite().publish(to: root.appendingPathComponent("out").path, from: "\(root.path)/Package.swift")
        } catch {
            caught = error
        }
        #expect(caught?.description == "Two pages are published at /pricing/")
    }

    @Test func packageRootFallsBackToTheWorkingDirectory() {
        #expect(DemoSite.packageRoot(from: "/definitely/not/a/package/main.swift").path
            == URL(fileURLWithPath: FileManager.default.currentDirectoryPath).path)
    }
}

@Suite struct FeedAndRobotsTests {
    private let items = [
        FeedItem(title: "Second & last", link: "/b/", summary: "B <summary>", date: Date(timeIntervalSince1970: 86_400),
                 author: "Ana", categories: ["swift", "web"], contentHTML: "<p>B</p>"),
        FeedItem(title: "First", link: "https://elsewhere.example/a", summary: "A", date: Date(timeIntervalSince1970: 0))
    ]
    private let generator = FeedGenerator(title: "Blog", siteURL: "https://blog.example/", description: "Posts", language: "en")

    @Test func formatsKnowTheirFiles() {
        #expect(FeedFormat.allCases.map(\.fileName) == ["feed.xml", "atom.xml", "feed.json"])
        #expect(FeedFormat.allCases.map(\.mimeType)
            == ["application/rss+xml", "application/atom+xml", "application/feed+json"])
    }

    @Test func rss() {
        let rss = generator.generate(items: items, format: .rss)
        #expect(rss.contains("<title>Second &amp; last</title>"))
        #expect(rss.contains("<link>https://blog.example/b/</link>"))
        #expect(rss.contains("<pubDate>Fri, 02 Jan 1970 00:00:00 +0000</pubDate>"))
        #expect(rss.contains("<link>https://elsewhere.example/a</link>"))
        #expect(rss.contains("<category>web</category>"))
    }

    @Test func atom() {
        let atom = generator.generate(items: items, format: .atom)
        #expect(atom.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\" xml:lang=\"en\">"))
        #expect(atom.contains("<link rel=\"self\" href=\"https://blog.example/atom.xml\"/>"))
        #expect(atom.contains("<updated>1970-01-02T00:00:00Z</updated>\n" + RenderOptions.pretty.indent + "<entry>"))
        #expect(atom.contains("<summary>B &lt;summary&gt;</summary>"))
        #expect(atom.contains("<author><name>Ana</name></author>"))
        #expect(atom.contains("<category term=\"swift\"/>"))
        #expect(atom.contains("<content type=\"html\">&lt;p&gt;B&lt;/p&gt;</content>"))
        #expect(atom.hasSuffix("</entry>\n</feed>"))
        let empty = FeedGenerator(title: "E", siteURL: "https://e.example", description: "").generate(items: [], format: .atom)
        #expect(empty.contains("<feed xmlns=\"http://www.w3.org/2005/Atom\">\n"))
        #expect(empty.contains("<updated>1970-01-01T00:00:00Z</updated>"))
    }

    @Test func jsonFeed() throws {
        let json = generator.generate(items: items, format: .json)
        let object = try #require(try JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])
        #expect(object["version"] as? String == "https://jsonfeed.org/version/1.1")
        #expect(object["feed_url"] as? String == "https://blog.example/feed.json")
        #expect(object["home_page_url"] as? String == "https://blog.example/")
        let entries = try #require(object["items"] as? [[String: Any]])
        #expect(entries.count == 2)
        #expect(entries[0]["url"] as? String == "https://blog.example/b/")
        #expect(entries[0]["date_published"] as? String == "1970-01-02T00:00:00Z")
        #expect(entries[0]["content_html"] as? String == "<p>B</p>")
        #expect((entries[0]["authors"] as? [[String: String]])?.first?["name"] == "Ana")
        #expect(entries[1]["tags"] == nil)
    }

    @Test func robots() {
        #expect(RobotsGenerator.generate() == "User-agent: *\nAllow: /\n")
        let custom = RobotsGenerator.generate(
            rules: [RobotsRule(disallow: ["/drafts/"]), RobotsRule(userAgent: "GPTBot", allow: [], disallow: ["/"])],
            sitemap: "https://example.com/sitemap.xml")
        #expect(custom == "User-agent: *\nAllow: /\nDisallow: /drafts/\n\nUser-agent: GPTBot\nDisallow: /\n\nSitemap: https://example.com/sitemap.xml\n")
    }

    @Test func xmlEscapeCoversEverySpecialCharacter() {
        #expect(XMLEscape.escape("a&b<c>d\"e'f") == "a&amp;b&lt;c&gt;d&quot;e&apos;f")
    }
}
