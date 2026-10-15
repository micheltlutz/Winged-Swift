import Foundation
import Testing
@testable import WingedSwift

private func caught(_ body: () throws(WingedError) -> Void) -> WingedError? {
    guard case .failure(let error) = Result(catching: body) else { return nil }
    return error
}

private func day(_ text: String) -> Date? {
    FrontMatter.parseDate(text)
}

@Suite struct FrontMatterTests {
    @Test func splitsKeysAndBody() throws {
        let source = """
        ---
        title: "Hello: world"
        # a comment
        Date: 2026-10-15
        tags: [swift, 'web dev', ]
        published: no
        summary: Short
        custom: value

        ---
        # Body
        """
        let (matter, body) = try FrontMatter.split(source)
        #expect(matter.title == "Hello: world")
        #expect(matter.date == day("2026-10-15"))
        #expect(matter.tags == ["swift", "web dev"])
        #expect(!matter.published)
        #expect(matter.description == "Short")
        #expect(matter["custom"] == "value")
        #expect(matter.author == nil && matter.image == nil && matter.path == nil)
        #expect(body == "# Body")
    }

    @Test func withoutFrontMatterTheBodyIsEverything() throws {
        let (matter, body) = try FrontMatter.split("# Just text\r\n")
        #expect(matter == FrontMatter())
        #expect(body == "# Just text\r\n")
        #expect(matter.tags.isEmpty && matter.published)
        #expect(FrontMatter(values: ["tags": "a, b"]).tags == ["a", "b"])
        #expect(FrontMatter(values: ["published": "TRUE"]).published)
    }

    @Test func readsSeveralDateFormats() {
        #expect(day("2026-10-15T09:30:00Z") != nil)
        #expect(day("2026-10-15 09:30") == day("2026-10-15T09:30:00Z"))
        #expect(day("2026-10-15T09:30") == day("2026-10-15T09:30:00Z"))
        #expect(day("2026-10-15 09:30:15") != nil)
        #expect(day("15/10/2026") == nil)
        #expect(FrontMatter.unquoted("'x'") == "x")
        #expect(FrontMatter.unquoted("\"") == "\"")
    }

    @Test func reportsWhereItBreaks() {
        let missing = caught { () throws(WingedError) in _ = try FrontMatter.split("---\ntitle: x\n", file: "a.md") }
        #expect(missing?.description == "a.md:3: invalid front matter — missing the closing ---")
        let noColon = caught { () throws(WingedError) in _ = try FrontMatter.split("---\njust words\n---", file: "b.md") }
        #expect(noColon?.description == "b.md:2: invalid front matter — expected `key: value`")
        let badDate = caught { () throws(WingedError) in _ = try FrontMatter.split("---\ndate: soon\n---\n", file: "c.md") }
        #expect(badDate?.description == "c.md:2: invalid front matter — cannot read the date \"soon\"")
        let emptyKey = caught { () throws(WingedError) in _ = try FrontMatter.split("---\n: x\n---") }
        #expect(emptyKey?.description == "<input>:2: invalid front matter — expected `key: value`")
    }
}

@Suite struct ContentPageTests {
    @Test func pathsComeFromTheFile() throws {
        #expect(ContentPage.path(for: "blog/hello-world.md") == "/blog/hello-world/")
        #expect(ContentPage.path(for: "blog/index.md") == "/blog/")
        #expect(ContentPage.path(for: "index.md") == "/")
        let custom = try ContentPage(source: "---\npath: /custom/\n---\nx", sourcePath: "a.md")
        #expect(custom.path == "/custom/")
    }

    @Test func titlesFallBack() throws {
        #expect(try ContentPage(source: "---\ntitle: Front\n---\n# Heading", sourcePath: "a.md").title == "Front")
        #expect(try ContentPage(source: "intro\n# The *Heading*", sourcePath: "a.md").title == "The Heading")
        #expect(try ContentPage(source: "no heading", sourcePath: "notes/my-file.md").title == "my-file")
    }

    @Test func countsWordsAndRendersContent() throws {
        let words = Array(repeating: "word", count: 600).joined(separator: " ")
        let page = try ContentPage(source: "# Title\n\n\(words)", sourcePath: "a.md")
        #expect(page.wordCount == 601)
        #expect(page.readingMinutes == 2)
        #expect(try ContentPage(source: "", sourcePath: "a.md").readingMinutes == 1)
        let html = Fragment(children: page.content(options: MarkdownOptions(headingIDs: false))).render(.compact)
        #expect(html.hasPrefix("<h1>Title</h1><p>word word"))
    }

    @Test func loadsNewestFirstAndSkipsDrafts() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("winged-content-\(UUID().uuidString)")
        let files = [
            "old.md": "---\ndate: 2026-01-01\n---\nold",
            "new.md": "---\ndate: 2026-06-01\n---\nnew",
            "same-b.md": "---\ndate: 2026-03-01\n---\nb",
            "same-a.md": "---\ndate: 2026-03-01\n---\na",
            "undated-z.md": "z",
            "undated-a.md": "a",
            "draft.md": "---\npublished: false\n---\ndraft",
            "notes.txt": "ignored",
            "nested/deep.md": "---\ndate: 2025-01-01\n---\ndeep"
        ]
        for (name, contents) in files {
            let url = root.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try contents.write(to: url, atomically: true, encoding: .utf8)
        }
        let paths = try ContentPage.load(from: root.path).map(\.path)
        #expect(paths == ["/new/", "/same-a/", "/same-b/", "/old/", "/nested/deep/", "/undated-a/", "/undated-z/"])
        #expect(try ContentPage.load(from: root.path, includeDrafts: true).count == 8)
        #expect(try ContentPage.load(from: root.path + "/missing").isEmpty)

        try Data([0xFF, 0xFE]).write(to: root.appendingPathComponent("binary.md"))
        let error = caught { () throws(WingedError) in _ = try ContentPage.load(from: root.path) }
        #expect(error?.description == "Could not read \(root.path)/binary.md as UTF-8 text")
    }
}

// MARK: - A site with Markdown content

private struct Home: Page {
    var title = "Blog"
    @Environment(\.content) var content

    var body: HTMLTag {
        Ul {
            for post in content {
                Li { A(href: post.path, content: post.title) }
            }
        }
    }
}

private struct Shell: PageLayout {
    func body(content: HTMLTag) -> [HTMLTag] { MainTag(children: [content]) }
}

private struct CardLayout: ContentLayout {
    func body(page: ContentPage, content: HTMLTag) -> HTMLTag {
        Div { H2(content: page.title); content }.addClass("card")
    }
}

private struct Blog: Site {
    var name = "Blog"
    var url = "https://blog.example"
    var author = "Ana"
    var homePage = Home()
    var layout = Shell()
    var generatesTagPages = true
    var markdownOptions = MarkdownOptions()
    var feedItems: [FeedItem] = []
}

private struct CardBlog: Site {
    var name = "Cards"
    var url = "https://cards.example"
    var homePage = Home()
    var layout = Shell()
    var contentLayout = CardLayout()
    var contentDirectory = "Posts"
}

private func package(with files: [String: String]) throws -> URL {
    let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("winged-blog-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    try "// swift-tools-version: 6.0".write(to: root.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
    for (name, contents) in files {
        let url = root.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
    return root
}

private let posts = [
    "Content/posts/first.md": "---\ntitle: First post\ndate: 2026-01-10\ntags: swift, web\ndescription: The first one\n---\nHello **world**.\n\n<b>raw</b>",
    "Content/posts/second.md": "---\ndate: 2026-02-20\ntags: Swift\nimage: /img/second.png\n---\n# Second post\n\nMore words here.",
    "Content/about.md": "# About\n\nNo date, no tags."
]

@Suite struct SiteContentTests {
    @Test func publishesMarkdownTagsAndAFeed() throws {
        let root = try package(with: posts)
        let report = try Blog().publish(to: "out", from: root.path + "/Package.swift")
        #expect(report.files == ["index.html", "posts/second/index.html", "posts/first/index.html", "about/index.html",
                                 "tags/index.html", "tags/swift/index.html", "tags/web/index.html", "404.html",
                                 "sitemap.xml", "robots.txt", "feed.xml"])
        let out = root.appendingPathComponent("out")
        let read = { (path: String) throws -> String in try String(contentsOf: out.appendingPathComponent(path), encoding: .utf8) }

        let home = try read("index.html")
        #expect(home.contains("<a href=\"/posts/second/\">Second post</a>"))
        #expect(home.contains("<link href=\"/feed.xml\" rel=\"alternate\" type=\"application/rss+xml\" title=\"Blog\">"))

        let first = try read("posts/first/index.html")
        #expect(first.contains("<title>First post — Blog</title>"))
        #expect(first.contains("<meta property=\"og:type\" content=\"article\">"))
        #expect(first.contains("<meta property=\"article:published_time\" content=\"2026-01-10T00:00:00Z\">"))
        #expect(first.contains("<time datetime=\"2026-01-10\">2026-01-10</time> <a href=\"/tags/swift/\" class=\"tag\">#swift</a>"))
        #expect(first.contains("<p>Hello <strong>world</strong>.</p>"))
        #expect(first.contains("&lt;b&gt;raw&lt;/b&gt;"))

        let tags = try read("tags/index.html")
        #expect(tags.contains("<a href=\"/tags/swift/\">#Swift</a> (2)"))
        #expect(try read("tags/web/index.html").contains("<a href=\"/posts/first/\">First post</a>"))

        let sitemap = try read("sitemap.xml")
        #expect(sitemap.contains("<loc>https://blog.example/posts/first/</loc>\n" + "    " + "<lastmod>2026-01-10</lastmod>"))
        let feed = try read("feed.xml")
        #expect(feed.contains("<title>Second post</title>"))
        #expect(feed.contains("<description>The first one</description>"))
        #expect(feed.contains("<description>Second post More words here.</description>"))
        #expect(!feed.contains("About"))
    }

    @Test func tagsThatShareASlugAreOneTag() throws {
        let a = try ContentPage(source: "---\ntags: Swift, swift, SWIFT\n---\n", sourcePath: "a.md")
        let b = try ContentPage(source: "---\ntags: swift\n---\n", sourcePath: "b.md")
        let groups = TagPages.group([a, b])
        #expect(groups.map(\.tag) == ["Swift"])
        #expect(groups.first?.pages.map(\.path) == ["/a/", "/b/"])
    }

    @Test func optionsChangeWhatIsGenerated() throws {
        let root = try package(with: posts)
        var blog = Blog()
        blog.generatesTagPages = false
        blog.markdownOptions = MarkdownOptions(rawHTML: true)
        blog.feedItems = [FeedItem(title: "Declared", link: "/x/", summary: "x", date: Date(timeIntervalSince1970: 0))]
        let report = try blog.publish(to: "out", from: root.path + "/Package.swift")
        #expect(!report.files.contains { $0.hasPrefix("tags/") })
        let out = root.appendingPathComponent("out")
        #expect(try String(contentsOf: out.appendingPathComponent("posts/first/index.html"), encoding: .utf8).contains("<b>raw</b>"))
        let feed = try String(contentsOf: out.appendingPathComponent("feed.xml"), encoding: .utf8)
        #expect(feed.contains("<title>Declared</title>") && !feed.contains("First post"))
    }

    @Test func customContentLayoutAndFolder() throws {
        let root = try package(with: ["Posts/a.md": "---\ntitle: A\n---\nbody"])
        let document = try #require(try CardBlog().document(at: "/a/", from: root.path + "/Package.swift"))
        #expect(document.render(.compact).contains("<main><div class=\"card\"><h2>A</h2><p>body</p></div></main>"))
        #expect(try CardBlog().contentPages(from: root.path + "/Package.swift").count == 1)
        let empty = try package(with: [:])
        #expect(try CardBlog().contentPages(from: empty.path + "/Package.swift").isEmpty)
    }

    @Test func invalidContentStopsThePublish() throws {
        let root = try package(with: ["Content/bad.md": "---\ntitle: x"])
        let error = caught { () throws(WingedError) in try Blog().publish(to: "out", from: root.path + "/Package.swift") }
        #expect(error?.description == "bad.md:2: invalid front matter — missing the closing ---")
        let renderError = caught { () throws(WingedError) in _ = try Blog().document(at: "/", from: root.path + "/Package.swift") }
        #expect(renderError != nil)
    }

    @Test func defaultLayoutsRender() throws {
        let undated = try ContentPage(source: "text", sourcePath: "a.md")
        let plain = DefaultContentLayout().body(page: undated, content: P(content: "c")).render(.compact)
        #expect(plain == "<article><header><h1>a</h1></header><p>c</p></article>")
        let tagged = try ContentPage(source: "---\ntags: x\n---\n", sourcePath: "b.md")
        #expect(DefaultContentLayout().body(page: tagged, content: Fragment()).render(.compact)
            == "<article><header><h1>b</h1><p class=\"meta\"> <a href=\"/tags/x/\" class=\"tag\">#x</a></p></header></article>")
        #expect(DefaultTagLayout().body(tag: "x", pages: [tagged]).render(.compact)
            == "<h1>#x</h1><ul><li><a href=\"/b/\">b</a></li></ul>")
        #expect(DefaultTagLayout().indexBody(tags: TagPages.group([tagged, undated])).render(.compact)
            == "<h1>Tags</h1><ul><li><a href=\"/tags/x/\">#x</a> (1)</li></ul>")
        #expect(tagSlug("C++ & Swift!") == "c-swift")
        #expect(ContentPage.tagPath("Server Side") == "/tags/server-side/")
        #expect(tagSlug("!!!") == "tag")
        #expect(TagPages.group([]).isEmpty)
    }
}
