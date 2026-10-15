import Foundation

/// One HTML page of a ``Site``.
///
/// Only `title` and `body` are required. The path defaults to the type name as a slug, without a
/// trailing `Page`: `AboutPage` and `About` are both served at `/about/`.
///
/// ## Example
/// ```swift
/// struct About: Page {
///     var title = "About"
///     var description = "Who we are"
///
///     var body: HTMLTag {
///         H1(content: "About")
///         P(content: "Built with WingedSwift.")
///     }
/// }
/// ```
public protocol Page {
    /// The page title, without the site name.
    var title: String { get }
    /// The page description for search engines and social cards. Empty (the default) falls back
    /// to the site's.
    var description: String { get }
    /// The served path: a directory (`/about/`, written as `about/index.html`) or a file
    /// (`/feed.html`). Defaults to the type name as a slug.
    var path: String { get }
    /// An image for social cards, absolute or root-relative. Empty (the default) falls back to the
    /// site's.
    var image: String { get }
    /// Whether the page is listed in `sitemap.xml`. Defaults to `true`.
    var isInSitemap: Bool { get }
    /// The page content, placed inside the layout.
    @HTMLBuilder var body: HTMLTag { get }
}

extension Page {
    public var description: String { "" }
    public var image: String { "" }
    public var isInSitemap: Bool { true }
    public var path: String { "/\(Self.slug(String(describing: Self.self)))/" }

    /// Converts a type name into a URL slug: `ContactUsPage` → `contact-us`.
    static func slug(_ typeName: String) -> String {
        var name = typeName
        if name.hasSuffix("Page") && name.count > 4 {
            name.removeLast(4)
        }
        var slug = ""
        var previous: Character?
        for character in name {
            if character.isUppercase, let previous, previous.isLowercase || previous.isNumber {
                slug.append("-")
            }
            slug.append(character.isLetter || character.isNumber ? Character(character.lowercased()) : "-")
            previous = character
        }
        return slug
    }
}

/// The shell shared by the pages of a ``Site``: what goes in `<head>` besides the generated meta
/// tags, and what surrounds each page's body.
///
/// The site already writes the charset, viewport, `<title>`, description, canonical link, Open
/// Graph and Twitter tags; the layout adds stylesheets, scripts and fonts.
///
/// ## Example
/// ```swift
/// struct MainLayout: PageLayout {
///     func head() -> [HTMLTag] {
///         [Link(href: "/css/style.css", rel: "stylesheet")]
///     }
///
///     func body(content: HTMLTag) -> [HTMLTag] {
///         [Header { Nav { A(href: "/", content: "Home") } },
///          MainTag(children: [content]),
///          SiteFooter().body]
///     }
/// }
/// ```
public protocol PageLayout {
    /// Extra elements for `<head>`. Defaults to none.
    @HTMLFragmentBuilder func head() -> [HTMLTag]
    /// The children of `<body>`, given the page content.
    @HTMLFragmentBuilder func body(content: HTMLTag) -> [HTMLTag]
}

extension PageLayout {
    public func head() -> [HTMLTag] { [] }
}

/// A layout that places the page content directly in `<body>`.
public struct EmptyLayout: PageLayout {
    /// Creates the layout.
    public init() {}

    public func body(content: HTMLTag) -> [HTMLTag] { [content] }
}

/// A result builder that collects the pages of a site.
@resultBuilder
public struct PageBuilder {
    public static func buildBlock(_ components: [any Page]...) -> [any Page] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: some Page) -> [any Page] {
        [expression]
    }

    public static func buildExpression(_ expression: [any Page]) -> [any Page] {
        expression
    }

    public static func buildOptional(_ component: [any Page]?) -> [any Page] {
        component ?? []
    }

    public static func buildEither(first component: [any Page]) -> [any Page] {
        component
    }

    public static func buildEither(second component: [any Page]) -> [any Page] {
        component
    }

    public static func buildArray(_ components: [[any Page]]) -> [any Page] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [any Page]) -> [any Page] {
        component
    }
}
