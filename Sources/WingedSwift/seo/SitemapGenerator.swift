import Foundation

/// Represents a URL entry in a sitemap.
public struct SitemapURL {
    /// The location (URL) of the page.
    public let loc: String
    
    /// The date of last modification in ISO 8601 format (optional).
    public let lastmod: String?
    
    /// How frequently the page is likely to change (optional).
    /// Valid values: "always", "hourly", "daily", "weekly", "monthly", "yearly", "never"
    public let changefreq: String?
    
    /// The priority of this URL relative to other URLs on the site (0.0 to 1.0, optional).
    public let priority: Double?
    
    /// Initializes a new sitemap URL entry.
    ///
    /// - Parameters:
    ///   - loc: The location (URL) of the page.
    ///   - lastmod: The date of last modification (optional).
    ///   - changefreq: How frequently the page changes (optional).
    ///   - priority: The priority of this URL (0.0 to 1.0, optional).
    public init(loc: String, lastmod: String? = nil, changefreq: String? = nil, priority: Double? = nil) {
        self.loc = loc
        self.lastmod = lastmod
        self.changefreq = changefreq
        self.priority = priority
    }
}

/// Generates XML sitemaps for search engines.
///
/// Sitemaps help search engines discover and index pages on your website.
///
/// ## Example
/// ```swift
/// let urls = [
///     SitemapURL(loc: "https://example.com/", changefreq: "daily", priority: 1.0),
///     SitemapURL(loc: "https://example.com/about", changefreq: "monthly", priority: 0.8),
///     SitemapURL(loc: "https://example.com/blog", changefreq: "weekly", priority: 0.9)
/// ]
///
/// let sitemap = SitemapGenerator.generate(urls: urls)
/// try generator.writeFile(content: sitemap, to: "sitemap.xml")
/// ```
public struct SitemapGenerator {
    
    /// Generates an XML sitemap from an array of URLs.
    ///
    /// - Parameter urls: An array of SitemapURL entries.
    /// - Returns: The XML sitemap as a string.
    public static func generate(urls: [SitemapURL]) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        
        for url in urls {
            xml += "  <url>\n"
            xml += "    <loc>\(escapeXML(url.loc))</loc>\n"
            
            if let lastmod = url.lastmod {
                xml += "    <lastmod>\(escapeXML(lastmod))</lastmod>\n"
            }
            
            if let changefreq = url.changefreq {
                xml += "    <changefreq>\(escapeXML(changefreq))</changefreq>\n"
            }
            
            if let priority = url.priority {
                xml += "    <priority>\(priority)</priority>\n"
            }
            
            xml += "  </url>\n"
        }
        
        xml += "</urlset>"
        return xml
    }
    
    /// Generates a sitemap index file for multiple sitemaps.
    ///
    /// Use this when you have multiple sitemap files.
    ///
    /// - Parameter sitemaps: An array of tuples containing (sitemap URL, last modification date).
    /// - Returns: The XML sitemap index as a string.
    ///
    /// ## Example
    /// ```swift
    /// let index = SitemapGenerator.generateIndex(sitemaps: [
    ///     ("https://example.com/sitemap-posts.xml", "2024-01-15"),
    ///     ("https://example.com/sitemap-pages.xml", "2024-01-10")
    /// ])
    /// ```
    public static func generateIndex(sitemaps: [(loc: String, lastmod: String?)]) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        
        for sitemap in sitemaps {
            xml += "  <sitemap>\n"
            xml += "    <loc>\(escapeXML(sitemap.loc))</loc>\n"
            
            if let lastmod = sitemap.lastmod {
                xml += "    <lastmod>\(escapeXML(lastmod))</lastmod>\n"
            }
            
            xml += "  </sitemap>\n"
        }
        
        xml += "</sitemapindex>"
        return xml
    }
    
    /// Escapes XML special characters.
    ///
    /// - Parameter string: The string to escape.
    /// - Returns: The escaped string.
    private static func escapeXML(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        return result
    }
}
