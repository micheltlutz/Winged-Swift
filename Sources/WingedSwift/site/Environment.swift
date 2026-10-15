import Foundation

/// What a site says about itself, available to every page while it is published.
public struct SiteMetadata: Sendable, Equatable {
    /// The site name, used in titles and Open Graph `og:site_name`.
    public var name: String
    /// The absolute base URL, without a trailing slash (`https://example.com`).
    public var url: String
    /// The document language (`en`, `pt-BR`).
    public var language: String
    /// The default description, used when a page has none.
    public var description: String?
    /// The site author.
    public var author: String?

    /// Creates site metadata.
    ///
    /// - Parameters:
    ///   - name: The site name.
    ///   - url: The absolute base URL; a trailing slash is removed.
    ///   - language: The document language.
    ///   - description: The default description.
    ///   - author: The site author.
    public init(name: String = "", url: String = "", language: String = "en",
                description: String? = nil, author: String? = nil) {
        self.name = name
        self.url = url.hasSuffix("/") ? String(url.dropLast()) : url
        self.language = language
        self.description = description
        self.author = author
    }
}

/// What is known about the page being rendered.
public struct PageMetadata: Sendable, Equatable {
    /// The page title, without the site suffix.
    public var title: String
    /// The page description, falling back to the site's.
    public var description: String?
    /// The path the page is served at (`/`, `/about/`, `/404.html`).
    public var path: String
    /// The absolute URL of the page.
    public var url: String
    /// An absolute or root-relative image for social cards.
    public var image: String?
    /// The publication date, for pages generated from Markdown with a `date`.
    public var date: Date?

    /// Creates page metadata.
    ///
    /// - Parameters:
    ///   - title: The page title.
    ///   - description: The page description.
    ///   - path: The served path.
    ///   - url: The absolute URL.
    ///   - image: The social card image.
    ///   - date: The publication date.
    public init(title: String = "", description: String? = nil, path: String = "/",
                url: String = "", image: String? = nil, date: Date? = nil) {
        self.title = title
        self.description = description
        self.path = path
        self.url = url
        self.image = image
        self.date = date
    }
}

/// Values a page or component can read with ``Environment``.
///
/// ``Site/publish(to:from:)`` sets them for each page, scoped to the current thread for the
/// duration of the render, so there is no global state and two sites can publish concurrently on
/// different threads. Outside of a publish they hold empty defaults; use ``withValues(_:_:)`` to
/// set them in a test or a hand-written script.
public struct EnvironmentValues: Sendable {
    /// The site being published.
    public var site: SiteMetadata
    /// The page being rendered.
    public var page: PageMetadata
    /// Every page of the site, in publish order — useful for navigation and indexes.
    public var pages: [PageMetadata]
    /// The Markdown pages from `Content/`, newest first — for post lists and archives.
    public var content: [ContentPage]

    /// Creates a set of environment values.
    ///
    /// - Parameters:
    ///   - site: The site metadata.
    ///   - page: The current page.
    ///   - pages: Every page of the site.
    ///   - content: The Markdown pages.
    public init(site: SiteMetadata = SiteMetadata(), page: PageMetadata = PageMetadata(),
                pages: [PageMetadata] = [], content: [ContentPage] = []) {
        self.site = site
        self.page = page
        self.pages = pages
        self.content = content
    }

    private static let threadKey = "WingedSwift.EnvironmentValues"

    /// Holds the values in a thread dictionary, which only stores objects.
    private final class Box {
        let values: EnvironmentValues
        init(_ values: EnvironmentValues) { self.values = values }
    }

    // Thread-local rather than `@TaskLocal`, which would raise the deployment target to
    // macOS 10.15 for every site depending on the library. Rendering is synchronous, so the
    // values cannot leak across a suspension point.
    static var current: EnvironmentValues {
        (Thread.current.threadDictionary[threadKey] as? Box)?.values ?? EnvironmentValues()
    }

    /// Runs `body` with `values` as the environment.
    ///
    /// - Parameters:
    ///   - values: The environment to expose to ``Environment`` reads inside `body`.
    ///   - body: The work to run.
    /// - Returns: What `body` returns.
    ///
    /// ## Example
    /// ```swift
    /// let html = EnvironmentValues.withValues(EnvironmentValues(site: SiteMetadata(name: "Demo"))) {
    ///     SiteFooter().render()
    /// }
    /// ```
    public static func withValues<T>(_ values: EnvironmentValues, _ body: () throws -> T) rethrows -> T {
        let dictionary = Thread.current.threadDictionary
        let previous = dictionary[threadKey]
        dictionary[threadKey] = Box(values)
        defer { dictionary[threadKey] = previous }
        return try body()
    }
}

/// Reads a value from the environment of the page being published.
///
/// ## Example
/// ```swift
/// struct SiteFooter: Component {
///     @Environment(\.site) var site
///
///     var body: HTMLTag {
///         Footer { P(content: "© \(site.name)") }
///     }
/// }
/// ```
@propertyWrapper
public struct Environment<Value> {
    private let keyPath: KeyPath<EnvironmentValues, Value>

    /// Creates a reader for one environment value.
    ///
    /// - Parameter keyPath: The value to read, such as `\.site` or `\.page`.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    /// The current value, read when accessed.
    public var wrappedValue: Value {
        EnvironmentValues.current[keyPath: keyPath]
    }
}
