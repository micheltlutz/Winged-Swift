import Foundation

/// Represents an item in an RSS feed.
public struct RSSItem {
    /// The title of the item.
    public let title: String
    
    /// The URL of the item.
    public let link: String
    
    /// The item description or summary.
    public let description: String
    
    /// The publication date in RFC 822 format.
    public let pubDate: String
    
    /// The globally unique identifier for the item (optional).
    public let guid: String?
    
    /// The author of the item (optional).
    public let author: String?
    
    /// Categories the item belongs to (optional).
    public let categories: [String]?
    
    /// Initializes a new RSS item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - link: The URL of the item.
    ///   - description: The item description.
    ///   - pubDate: The publication date in RFC 822 format.
    ///   - guid: The globally unique identifier (optional).
    ///   - author: The author email (optional).
    ///   - categories: Categories for the item (optional).
    public init(
        title: String,
        link: String,
        description: String,
        pubDate: String,
        guid: String? = nil,
        author: String? = nil,
        categories: [String]? = nil
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.pubDate = pubDate
        self.guid = guid ?? link
        self.author = author
        self.categories = categories
    }
}

/// Generates RSS 2.0 feeds for blogs and content websites.
///
/// RSS feeds allow users to subscribe to your content updates.
///
/// ## Example
/// ```swift
/// let generator = RSSGenerator(
///     title: "My Blog",
///     link: "https://example.com",
///     description: "A blog about Swift and web development"
/// )
///
/// let items = [
///     RSSItem(
///         title: "First Post",
///         link: "https://example.com/posts/first",
///         description: "This is my first post",
///         pubDate: "Mon, 15 Jan 2024 12:00:00 GMT"
///     ),
///     RSSItem(
///         title: "Second Post",
///         link: "https://example.com/posts/second",
///         description: "This is my second post",
///         pubDate: "Tue, 16 Jan 2024 12:00:00 GMT"
///     )
/// ]
///
/// let rss = generator.generate(items: items)
/// try siteGenerator.writeFile(content: rss, to: "feed.xml")
/// ```
public class RSSGenerator {
    /// The title of the RSS feed.
    public let title: String
    
    /// The URL of the website.
    public let link: String
    
    /// The description of the feed.
    public let description: String
    
    /// The language of the feed (optional, e.g., "en-us").
    public let language: String?
    
    /// The copyright notice (optional).
    public let copyright: String?
    
    /// The email address for the managing editor (optional).
    public let managingEditor: String?
    
    /// The email address for the webmaster (optional).
    public let webmaster: String?
    
    /// Initializes a new RSS generator.
    ///
    /// - Parameters:
    ///   - title: The title of the RSS feed.
    ///   - link: The URL of the website.
    ///   - description: The description of the feed.
    ///   - language: The language of the feed (optional).
    ///   - copyright: The copyright notice (optional).
    ///   - managingEditor: The managing editor email (optional).
    ///   - webmaster: The webmaster email (optional).
    public init(
        title: String,
        link: String,
        description: String,
        language: String? = nil,
        copyright: String? = nil,
        managingEditor: String? = nil,
        webmaster: String? = nil
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.language = language
        self.copyright = copyright
        self.managingEditor = managingEditor
        self.webmaster = webmaster
    }
    
    /// Generates the RSS feed XML.
    ///
    /// - Parameter items: An array of RSS items to include in the feed.
    /// - Returns: The RSS feed XML as a string.
    public func generate(items: [RSSItem]) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\n"
        xml += "  <channel>\n"
        xml += "    <title>\(escapeXML(title))</title>\n"
        xml += "    <link>\(escapeXML(link))</link>\n"
        xml += "    <description>\(escapeXML(description))</description>\n"
        xml += "    <atom:link href=\"\(escapeXML(link))/feed.xml\" rel=\"self\" type=\"application/rss+xml\" />\n"
        
        if let language = language {
            xml += "    <language>\(escapeXML(language))</language>\n"
        }
        
        if let copyright = copyright {
            xml += "    <copyright>\(escapeXML(copyright))</copyright>\n"
        }
        
        if let managingEditor = managingEditor {
            xml += "    <managingEditor>\(escapeXML(managingEditor))</managingEditor>\n"
        }
        
        if let webmaster = webmaster {
            xml += "    <webMaster>\(escapeXML(webmaster))</webMaster>\n"
        }
        
        // Add items
        for item in items {
            xml += "    <item>\n"
            xml += "      <title>\(escapeXML(item.title))</title>\n"
            xml += "      <link>\(escapeXML(item.link))</link>\n"
            xml += "      <description>\(escapeXML(item.description))</description>\n"
            xml += "      <pubDate>\(escapeXML(item.pubDate))</pubDate>\n"
            
            if let guid = item.guid {
                xml += "      <guid isPermaLink=\"true\">\(escapeXML(guid))</guid>\n"
            }
            
            if let author = item.author {
                xml += "      <author>\(escapeXML(author))</author>\n"
            }
            
            if let categories = item.categories {
                for category in categories {
                    xml += "      <category>\(escapeXML(category))</category>\n"
                }
            }
            
            xml += "    </item>\n"
        }
        
        xml += "  </channel>\n"
        xml += "</rss>"
        
        return xml
    }
    
    /// Escapes XML special characters.
    ///
    /// - Parameter string: The string to escape.
    /// - Returns: The escaped string.
    private func escapeXML(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        return result
    }
}
