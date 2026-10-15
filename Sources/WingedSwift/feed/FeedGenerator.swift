import Foundation

/// The syndication formats ``FeedGenerator`` can write.
public enum FeedFormat: String, Sendable, CaseIterable {
    /// RSS 2.0, written to `feed.xml`.
    case rss
    /// Atom 1.0, written to `atom.xml`.
    case atom
    /// JSON Feed 1.1, written to `feed.json`.
    case json

    /// The file name a ``Site`` writes the feed to.
    public var fileName: String {
        switch self {
        case .rss: return "feed.xml"
        case .atom: return "atom.xml"
        case .json: return "feed.json"
        }
    }

    /// The MIME type for `<link rel="alternate">`.
    public var mimeType: String {
        switch self {
        case .rss: return "application/rss+xml"
        case .atom: return "application/atom+xml"
        case .json: return "application/feed+json"
        }
    }
}

/// One entry of a syndication feed, independent of the format.
public struct FeedItem: Sendable, Equatable {
    /// The entry title.
    public var title: String
    /// The absolute URL of the entry, or a root-relative path resolved against the site URL.
    public var link: String
    /// A plain-text summary.
    public var summary: String
    /// When the entry was published.
    public var date: Date
    /// The author's name.
    public var author: String?
    /// Tags or categories.
    public var categories: [String]
    /// The full HTML content, for readers that show whole entries.
    public var contentHTML: String?

    /// Creates a feed entry.
    ///
    /// - Parameters:
    ///   - title: The entry title.
    ///   - link: The absolute URL or root-relative path of the entry.
    ///   - summary: A plain-text summary.
    ///   - date: The publication date.
    ///   - author: The author's name.
    ///   - categories: Tags or categories.
    ///   - contentHTML: The full HTML content.
    public init(title: String, link: String, summary: String, date: Date, author: String? = nil,
                categories: [String] = [], contentHTML: String? = nil) {
        self.title = title
        self.link = link
        self.summary = summary
        self.date = date
        self.author = author
        self.categories = categories
        self.contentHTML = contentHTML
    }
}

/// Writes RSS 2.0, Atom 1.0 or JSON Feed 1.1 from the same ``FeedItem`` list.
///
/// ## Example
/// ```swift
/// let feed = FeedGenerator(title: "Blog", siteURL: "https://example.com", description: "Posts")
/// let atom = feed.generate(items: posts, format: .atom)
/// ```
public struct FeedGenerator: Sendable {
    /// The feed title.
    public var title: String
    /// The absolute site URL, without a trailing slash.
    public var siteURL: String
    /// The feed description.
    public var description: String
    /// The feed language.
    public var language: String?

    /// Creates a feed generator.
    ///
    /// - Parameters:
    ///   - title: The feed title.
    ///   - siteURL: The absolute site URL.
    ///   - description: The feed description.
    ///   - language: The feed language.
    public init(title: String, siteURL: String, description: String, language: String? = nil) {
        self.title = title
        self.siteURL = siteURL.hasSuffix("/") ? String(siteURL.dropLast()) : siteURL
        self.description = description
        self.language = language
    }

    /// Renders the feed.
    ///
    /// - Parameters:
    ///   - items: The entries, newest first.
    ///   - format: The output format.
    /// - Returns: The feed document.
    public func generate(items: [FeedItem], format: FeedFormat) -> String {
        switch format {
        case .rss: return rss(items)
        case .atom: return atom(items)
        case .json: return json(items)
        }
    }

    private func absolute(_ link: String) -> String {
        link.hasPrefix("/") ? siteURL + link : link
    }

    private func feedURL(_ format: FeedFormat) -> String {
        "\(siteURL)/\(format.fileName)"
    }

    private func rss(_ items: [FeedItem]) -> String {
        let rssItems = items.map { item in
            RSSItem(title: item.title, link: absolute(item.link), description: item.summary,
                    pubDate: Self.rfc822(item.date), author: item.author,
                    categories: item.categories.isEmpty ? nil : item.categories)
        }
        return RSSGenerator(title: title, link: siteURL, description: description, language: language)
            .generate(items: rssItems)
    }

    private func atom(_ items: [FeedItem]) -> String {
        let updated = items.map(\.date).max() ?? Date(timeIntervalSince1970: 0)
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<feed xmlns=\"http://www.w3.org/2005/Atom\""
        if let language {
            xml += " xml:lang=\"\(XMLEscape.escape(language))\""
        }
        xml += ">\n"
        xml += "  <title>\(XMLEscape.escape(title))</title>\n"
        xml += "  <subtitle>\(XMLEscape.escape(description))</subtitle>\n"
        xml += "  <link href=\"\(XMLEscape.escape(siteURL))/\"/>\n"
        xml += "  <link rel=\"self\" href=\"\(XMLEscape.escape(feedURL(.atom)))\"/>\n"
        xml += "  <id>\(XMLEscape.escape(siteURL))/</id>\n"
        xml += "  <updated>\(Self.rfc3339(updated))</updated>\n"
        for item in items {
            let link = XMLEscape.escape(absolute(item.link))
            xml += "  <entry>\n"
            xml += "    <title>\(XMLEscape.escape(item.title))</title>\n"
            xml += "    <link href=\"\(link)\"/>\n"
            xml += "    <id>\(link)</id>\n"
            xml += "    <updated>\(Self.rfc3339(item.date))</updated>\n"
            xml += "    <summary>\(XMLEscape.escape(item.summary))</summary>\n"
            if let author = item.author {
                xml += "    <author><name>\(XMLEscape.escape(author))</name></author>\n"
            }
            for category in item.categories {
                xml += "    <category term=\"\(XMLEscape.escape(category))\"/>\n"
            }
            if let content = item.contentHTML {
                xml += "    <content type=\"html\">\(XMLEscape.escape(content))</content>\n"
            }
            xml += "  </entry>\n"
        }
        xml += "</feed>"
        return xml
    }

    private func json(_ items: [FeedItem]) -> String {
        let feed = JSONFeedDocument(
            version: "https://jsonfeed.org/version/1.1",
            title: title,
            homePageURL: siteURL + "/",
            feedURL: feedURL(.json),
            description: description,
            language: language,
            items: items.map { item in
                JSONFeedItem(
                    id: absolute(item.link), url: absolute(item.link), title: item.title,
                    summary: item.summary, contentHTML: item.contentHTML,
                    datePublished: Self.rfc3339(item.date),
                    authors: item.author.map { [["name": $0]] },
                    tags: item.categories.isEmpty ? nil : item.categories)
            })
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        // Encoding plain strings and arrays cannot fail.
        let data = (try? encoder.encode(feed)) ?? Data()
        return String(bytes: data, encoding: .utf8) ?? ""
    }

    static func rfc822(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return formatter.string(from: date)
    }

    static func rfc3339(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

private struct JSONFeedItem: Encodable {
    let id: String
    let url: String
    let title: String
    let summary: String
    let contentHTML: String?
    let datePublished: String
    let authors: [[String: String]]?
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id, url, title, summary, authors, tags
        case contentHTML = "content_html"
        case datePublished = "date_published"
    }
}

private struct JSONFeedDocument: Encodable {
    let version: String
    let title: String
    let homePageURL: String
    let feedURL: String
    let description: String
    let language: String?
    let items: [JSONFeedItem]

    enum CodingKeys: String, CodingKey {
        case version, title, description, language, items
        case homePageURL = "home_page_url"
        case feedURL = "feed_url"
    }
}

/// Escapes text for XML element content and attribute values.
enum XMLEscape {
    static func escape(_ string: String) -> String {
        var result = ""
        result.reserveCapacity(string.count)
        for character in string {
            switch character {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"": result += "&quot;"
            case "'": result += "&apos;"
            default: result.append(character)
            }
        }
        return result
    }
}
