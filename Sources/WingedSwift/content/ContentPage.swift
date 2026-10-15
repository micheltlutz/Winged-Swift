import Foundation

/// A Markdown file from the site's `Content/` folder, with its front matter.
///
/// Every published file becomes a page, rendered through the site's ``ContentLayout``. Its path comes from the file:
/// `Content/blog/hello-world.md` is served at `/blog/hello-world/`, and an `index.md` at its
/// folder's path. `path:` in the front matter overrides that.
public struct ContentPage: Sendable, Equatable {
    /// The served path, such as `/blog/hello-world/`.
    public var path: String
    /// The file, relative to the content folder, such as `blog/hello-world.md`.
    public var sourcePath: String
    /// The front matter `title`, else the first `# heading`, else the file name.
    public var title: String
    /// The front matter `description`.
    public var description: String?
    /// The front matter `date`.
    public var date: Date?
    /// The front matter `tags`.
    public var tags: [String]
    /// The front matter `author`.
    public var author: String?
    /// The front matter `image`.
    public var image: String?
    /// Whether the page is published; drafts (`published: false`) are skipped.
    public var published: Bool
    /// Every front matter value, for your own keys.
    public var frontMatter: FrontMatter
    /// The Markdown after the front matter.
    public var markdown: String

    /// Words in the text.
    public var wordCount: Int {
        Markdown.plainText(markdown).split(separator: " ").count
    }

    /// Minutes to read at 250 words per minute, at least 1.
    public var readingMinutes: Int {
        max(1, Int((Double(wordCount) / 250).rounded()))
    }

    /// The rendered body.
    ///
    /// - Parameter options: How to render the Markdown.
    /// - Returns: The block-level tags.
    public func content(options: MarkdownOptions = MarkdownOptions()) -> [HTMLTag] {
        Markdown.parse(markdown, options: options)
    }

    /// Reads a content page from Markdown.
    ///
    /// - Parameters:
    ///   - source: The file contents, front matter included.
    ///   - sourcePath: The file path relative to the content folder; it decides the default path.
    /// - Throws: ``WingedError/invalidFrontMatter(file:line:reason:)``.
    public init(source: String, sourcePath: String) throws(WingedError) {
        let (matter, body) = try FrontMatter.split(source, file: sourcePath)
        self.sourcePath = sourcePath
        self.frontMatter = matter
        self.markdown = body
        self.description = matter.description
        self.date = matter.date
        self.tags = matter.tags
        self.author = matter.author
        self.image = matter.image
        self.published = matter.published
        self.path = matter.path ?? Self.path(for: sourcePath)
        let heading = body.components(separatedBy: "\n").lazy
            .compactMap { line -> String? in line.hasPrefix("# ") ? String(line.dropFirst(2)) : nil }.first
        let fileName = ((sourcePath as NSString).lastPathComponent as NSString).deletingPathExtension
        self.title = matter.title ?? heading.map(Markdown.plainText) ?? fileName
    }

    /// The path of the page listing everything tagged `tag` (`Server Side` → `/tags/server-side/`).
    ///
    /// - Parameter tag: A tag as written in front matter.
    /// - Returns: The served path of its tag page.
    public static func tagPath(_ tag: String) -> String {
        TagPages.path(for: tag)
    }

    /// `blog/hello.md` → `/blog/hello/`, `blog/index.md` → `/blog/`, `index.md` → `/`.
    static func path(for sourcePath: String) -> String {
        var components = (sourcePath as NSString).deletingPathExtension.split(separator: "/").map(String.init)
        if components.last == "index" {
            components.removeLast()
        }
        return components.isEmpty ? "/" : "/" + components.joined(separator: "/") + "/"
    }

    /// Loads every `.md` file under `directory`, newest first, then by path.
    ///
    /// - Parameters:
    ///   - directory: The content folder. A missing folder means no pages.
    ///   - includeDrafts: Keep pages with `published: false`. Defaults to `false`.
    /// - Returns: The pages.
    /// - Throws: ``WingedError`` if a file cannot be read or has invalid front matter.
    public static func load(from directory: String, includeDrafts: Bool = false) throws(WingedError) -> [ContentPage] {
        guard let files = FileManager.default.subpaths(atPath: directory) else { return [] }
        var pages: [ContentPage] = []
        for file in files.sorted() where file.hasSuffix(".md") {
            let fullPath = "\(directory)/\(file)"
            guard let data = FileManager.default.contents(atPath: fullPath),
                  let source = String(bytes: data, encoding: .utf8) else {
                throw .unreadableContent(path: fullPath)
            }
            let page = try ContentPage(source: source, sourcePath: file)
            if page.published || includeDrafts {
                pages.append(page)
            }
        }
        return pages.sorted { lhs, rhs in
            switch (lhs.date, rhs.date) {
            case let (left?, right?) where left != right: return left > right
            case (.some, nil): return true
            case (nil, .some): return false
            default: return lhs.path < rhs.path
            }
        }
    }
}
