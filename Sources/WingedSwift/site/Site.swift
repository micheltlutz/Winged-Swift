import Foundation

/// A whole static site, declared as a type and written to disk by ``publish(to:from:)``.
///
/// Only `name`, `url`, `homePage` and `layout` are required; everything else has a default.
/// Publishing renders every page through the layout, adds the meta tags, copies `assets/`, and
/// writes `404.html`, `sitemap.xml`, `robots.txt` and — when there are feed items — a feed.
///
/// ## Example
/// ```swift
/// struct MySite: Site {
///     var name = "RideKeeper"
///     var url = "https://ridekeeper.example"
///     var homePage = Home()
///     var layout = MainLayout()
///
///     var pages: [any Page] {
///         About()
///         Pricing()
///     }
/// }
///
/// try MySite().publish()
/// ```
public protocol Site {
    /// The type of the page served at `/`.
    associatedtype HomePageType: Page
    /// The type of the default layout.
    associatedtype LayoutType: PageLayout
    /// The type of the page written to `404.html`.
    associatedtype ErrorPageType: Page = NotFoundPage

    /// The site name, shown in titles and social cards.
    var name: String { get }
    /// The absolute base URL (`https://example.com`), used for canonical links, the sitemap and
    /// feeds.
    var url: String { get }
    /// The document language. Defaults to `"en"`.
    var language: String { get }
    /// The default page description. Defaults to empty.
    var description: String { get }
    /// The site author, written as `<meta name="author">`. Defaults to empty (omitted).
    var author: String { get }
    /// The default social-card image, absolute or root-relative. Defaults to empty (omitted).
    var image: String { get }
    /// The Twitter/X handle of the site (`@handle`). Defaults to empty (omitted).
    var twitterSite: String { get }
    /// The page served at `/`.
    var homePage: HomePageType { get }
    /// The other pages, in the order they are published.
    @PageBuilder var pages: [any Page] { get }
    /// The default layout.
    var layout: LayoutType { get }
    /// The page written to `404.html`. Defaults to ``NotFoundPage``.
    var errorPage: ErrorPageType { get }
    /// Entries for the site feed. Defaults to none, in which case no feed is written.
    var feedItems: [FeedItem] { get }
    /// The format of the site feed. Defaults to ``FeedFormat/rss``.
    var feedFormat: FeedFormat { get }
    /// The `robots.txt` rules. Defaults to allowing everything.
    var robotsRules: [RobotsRule] { get }
    /// The directory, relative to the package root, whose contents are copied into the output.
    /// Defaults to `"assets"`; a missing directory is skipped.
    var assetsDirectory: String { get }
    /// How pages are formatted. Defaults to ``RenderOptions/pretty``.
    var renderOptions: RenderOptions { get }

    /// The layout for one page. Defaults to ``layout``.
    func layout(for page: any Page) -> any PageLayout
    /// The full `<title>` for one page. Defaults to `"<page> — <site>"`, or the site name alone on
    /// the home page and pages titled like the site.
    func title(for page: PageMetadata) -> String
}

extension Site {
    public var language: String { "en" }
    public var description: String { "" }
    public var author: String { "" }
    public var image: String { "" }
    public var twitterSite: String { "" }
    public var pages: [any Page] { [] }
    public var feedItems: [FeedItem] { [] }
    public var feedFormat: FeedFormat { .rss }
    public var robotsRules: [RobotsRule] { [.allowAll] }
    public var assetsDirectory: String { "assets" }
    public var renderOptions: RenderOptions { .pretty }

    public func layout(for page: any Page) -> any PageLayout { layout }

    public func title(for page: PageMetadata) -> String {
        page.path == "/" || page.title.isEmpty || page.title == name ? name : "\(page.title) — \(name)"
    }
}

extension Site where ErrorPageType == NotFoundPage {
    public var errorPage: NotFoundPage { NotFoundPage() }
}

/// The default `404.html`: a heading and a link home, inside the site layout.
public struct NotFoundPage: Page {
    public var title = "Page not found"
    public var path = "/404.html"
    public var isInSitemap = false

    /// Creates the page.
    public init() {}

    public var body: HTMLTag {
        H1(content: "Page not found")
        P {
            "The page you are looking for does not exist. "
            A(href: "/", content: "Go to the home page")
            "."
        }
    }
}

/// What ``Site/publish(to:from:)`` wrote.
public struct PublishReport: Sendable, Equatable {
    /// The absolute output directory.
    public var outputDirectory: String
    /// The files written, relative to the output directory, in order (assets excluded).
    public var files: [String]
}

extension Site {
    /// Metadata for every page, home first and the error page last.
    var allPages: [(page: any Page, metadata: PageMetadata)] {
        let site = metadata
        let entries: [(any Page, String)] = [(homePage, "/")] + pages.map { ($0, $0.path) }
            + [(errorPage, errorPage.path)]
        return entries.map { page, path in
            let normalized = Self.normalize(path)
            return (page, PageMetadata(
                title: page.title,
                description: page.description.isEmpty ? site.description : page.description,
                path: normalized,
                url: site.url + normalized,
                image: page.image.isEmpty ? (image.isEmpty ? nil : image) : page.image))
        }
    }

    /// The site's own metadata, as pages see it in the environment.
    public var metadata: SiteMetadata {
        SiteMetadata(name: name, url: url, language: language,
                     description: description.isEmpty ? nil : description,
                     author: author.isEmpty ? nil : author)
    }

    /// Renders the page published at `path` into a complete document, without writing anything.
    /// `publish` produces exactly this for every page; use it to assert on a page in a test.
    ///
    /// - Parameter path: The served path, such as `"/"`, `"/about/"` or `"/404.html"`.
    /// - Returns: The document, or `nil` if no page is published at `path`.
    public func document(at path: String) -> Document? {
        let all = allPages
        let path = Self.normalize(path)
        guard let entry = all.first(where: { $0.metadata.path == path }) else { return nil }
        return render(entry.page, metadata: entry.metadata, pages: all.map(\.metadata))
    }

    private func render(_ page: any Page, metadata: PageMetadata, pages: [PageMetadata]) -> Document {
        let values = EnvironmentValues(site: self.metadata, page: metadata, pages: pages)
        return EnvironmentValues.withValues(values) {
            let layout = layout(for: page)
            return Document(lang: language) {
                headTags(for: metadata)
                layout.head()
            } body: {
                layout.body(content: page.body)
            }
        }
    }

    @HTMLFragmentBuilder
    private func headTags(for page: PageMetadata) -> [HTMLTag] {
        let title = title(for: page)
        Meta(charset: "UTF-8")
        Meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
        Title(content: title)
        if let description = page.description {
            Meta(name: "description", content: description)
        }
        if !author.isEmpty {
            Meta(name: "author", content: author)
        }
        if page.path != errorPage.path {
            Link(href: page.url, rel: "canonical")
        }
        if !feedItems.isEmpty {
            Link(href: "/\(feedFormat.fileName)", rel: "alternate")
                .setAttribute(key: "type", value: feedFormat.mimeType)
                .setAttribute(key: "title", value: name)
        }
        Meta(property: "og:title", content: title)
        Meta(property: "og:type", content: "website")
        Meta(property: "og:url", content: page.url)
        Meta(property: "og:site_name", content: name)
        if let description = page.description {
            Meta(property: "og:description", content: description)
        }
        if let image = page.image {
            Meta(property: "og:image", content: image.hasPrefix("/") ? metadata.url + image : image)
        }
        Meta(name: "twitter:card", content: page.image == nil ? "summary" : "summary_large_image")
        if !twitterSite.isEmpty {
            Meta(name: "twitter:site", content: twitterSite)
        }
    }

    /// Writes the whole site.
    ///
    /// - Parameters:
    ///   - outputDirectory: Where to write, absolute or relative to the package root. Defaults to
    ///     the first command-line argument — which is what `winged build` passes — or `dist`.
    ///   - file: Leave the default. It locates the package root (the nearest folder above this
    ///     source file containing `Package.swift`), so the output does not depend on the working
    ///     directory.
    /// - Returns: What was written.
    /// - Throws: ``WingedError`` if two pages share a path or a file cannot be written.
    @discardableResult
    public func publish(to outputDirectory: String? = nil, from file: String = #filePath)
        throws(WingedError) -> PublishReport {
        let root = Self.packageRoot(from: file)
        let requested = outputDirectory ?? CommandLine.arguments.dropFirst().first ?? "dist"
        let output = requested.hasPrefix("/") ? requested : root.appendingPathComponent(requested).path
        let generator = StaticSiteGenerator(outputDirectory: output)
        let all = allPages

        var seen = Set<String>()
        for entry in all where !seen.insert(entry.metadata.path).inserted {
            throw .duplicatePath(entry.metadata.path)
        }

        try generator.clean()
        let assets = root.appendingPathComponent(assetsDirectory).path
        if let items = try? FileManager.default.contentsOfDirectory(atPath: assets) {
            for item in items.sorted() where !item.hasPrefix(".") {
                try generator.copyAsset(from: "\(assets)/\(item)", to: item)
            }
        }

        var files: [String] = []
        for entry in all {
            let file = Self.filePath(for: entry.metadata.path)
            let document = render(entry.page, metadata: entry.metadata, pages: all.map(\.metadata))
            try generator.generate(document: document, to: file, options: renderOptions)
            files.append(file)
        }

        let sitemap = all.filter { $0.page.isInSitemap && $0.metadata.path != errorPage.path }
            .map { SitemapURL(loc: $0.metadata.url) }
        try generator.writeFile(content: SitemapGenerator.generate(urls: sitemap), to: "sitemap.xml")
        try generator.writeFile(content: RobotsGenerator.generate(rules: robotsRules, sitemap: "\(metadata.url)/sitemap.xml"),
                                to: "robots.txt")
        files += ["sitemap.xml", "robots.txt"]

        if !feedItems.isEmpty {
            let feed = FeedGenerator(title: name, siteURL: metadata.url, description: description, language: language)
            try generator.writeFile(content: feed.generate(items: feedItems, format: feedFormat), to: feedFormat.fileName)
            files.append(feedFormat.fileName)
        }

        return PublishReport(outputDirectory: output, files: files)
    }

    /// `/about` and `about/` become `/about/`; paths ending in an extension are kept as files.
    static func normalize(_ path: String) -> String {
        var path = path.hasPrefix("/") ? path : "/" + path
        if !path.hasSuffix("/") && !(path.split(separator: "/").last?.contains(".") ?? false) {
            path += "/"
        }
        return path
    }

    /// `/` → `index.html`, `/about/` → `about/index.html`, `/404.html` → `404.html`.
    static func filePath(for path: String) -> String {
        let trimmed = String(path.dropFirst())
        return trimmed.isEmpty || trimmed.hasSuffix("/") ? trimmed + "index.html" : trimmed
    }

    static func packageRoot(from file: String) -> URL {
        var directory = URL(fileURLWithPath: file).deletingLastPathComponent()
        while directory.path != "/" {
            if FileManager.default.fileExists(atPath: directory.appendingPathComponent("Package.swift").path) {
                return directory
            }
            directory.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
