import Foundation

/// Provides helper methods for common SEO meta tags.
public struct SEO {
    
    // MARK: - Open Graph Meta Tags
    
    /// Generates Open Graph meta tags for social media sharing.
    ///
    /// - Parameters:
    ///   - title: The title of the page.
    ///   - description: The description of the page.
    ///   - image: The URL of the preview image.
    ///   - url: The canonical URL of the page.
    ///   - type: The type of content (default: "website").
    ///   - siteName: The name of the site (optional).
    /// - Returns: An array of Meta tags for Open Graph.
    ///
    /// ## Example
    /// ```swift
    /// let ogTags = SEO.openGraph(
    ///     title: "My Awesome Page",
    ///     description: "This is an amazing page",
    ///     image: "https://example.com/image.jpg",
    ///     url: "https://example.com/page"
    /// )
    /// ```
    public static func openGraph(
        title: String,
        description: String,
        image: String,
        url: String,
        type: String = "website",
        siteName: String? = nil
    ) -> [Meta] {
        var tags = [
            Meta(property: "og:title", content: title),
            Meta(property: "og:description", content: description),
            Meta(property: "og:image", content: image),
            Meta(property: "og:url", content: url),
            Meta(property: "og:type", content: type)
        ]
        
        if let siteName = siteName {
            tags.append(Meta(property: "og:site_name", content: siteName))
        }
        
        return tags
    }
    
    /// Generates Open Graph meta tags for an article.
    ///
    /// - Parameters:
    ///   - title: The title of the article.
    ///   - description: The description of the article.
    ///   - image: The URL of the preview image.
    ///   - url: The canonical URL of the article.
    ///   - author: The author of the article (optional).
    ///   - publishedTime: The publication time in ISO 8601 format (optional).
    ///   - modifiedTime: The modification time in ISO 8601 format (optional).
    /// - Returns: An array of Meta tags for an article.
    public static func openGraphArticle(
        title: String,
        description: String,
        image: String,
        url: String,
        author: String? = nil,
        publishedTime: String? = nil,
        modifiedTime: String? = nil
    ) -> [Meta] {
        var tags = openGraph(
            title: title,
            description: description,
            image: image,
            url: url,
            type: "article"
        )
        
        if let author = author {
            tags.append(Meta(property: "article:author", content: author))
        }
        
        if let publishedTime = publishedTime {
            tags.append(Meta(property: "article:published_time", content: publishedTime))
        }
        
        if let modifiedTime = modifiedTime {
            tags.append(Meta(property: "article:modified_time", content: modifiedTime))
        }
        
        return tags
    }
    
    // MARK: - Twitter Card Meta Tags
    
    /// Generates Twitter Card meta tags.
    ///
    /// - Parameters:
    ///   - title: The title of the page.
    ///   - description: The description of the page.
    ///   - image: The URL of the preview image.
    ///   - card: The type of Twitter Card (default: "summary_large_image").
    ///   - site: The Twitter username of the website (optional).
    ///   - creator: The Twitter username of the content creator (optional).
    /// - Returns: An array of Meta tags for Twitter Cards.
    ///
    /// ## Example
    /// ```swift
    /// let twitterTags = SEO.twitterCard(
    ///     title: "My Awesome Page",
    ///     description: "This is an amazing page",
    ///     image: "https://example.com/image.jpg",
    ///     site: "@mysite",
    ///     creator: "@author"
    /// )
    /// ```
    public static func twitterCard(
        title: String,
        description: String,
        image: String,
        card: String = "summary_large_image",
        site: String? = nil,
        creator: String? = nil
    ) -> [Meta] {
        var tags = [
            Meta(name: "twitter:card", content: card),
            Meta(name: "twitter:title", content: title),
            Meta(name: "twitter:description", content: description),
            Meta(name: "twitter:image", content: image)
        ]
        
        if let site = site {
            tags.append(Meta(name: "twitter:site", content: site))
        }
        
        if let creator = creator {
            tags.append(Meta(name: "twitter:creator", content: creator))
        }
        
        return tags
    }
    
    // MARK: - Common SEO Meta Tags
    
    /// Generates common SEO meta tags.
    ///
    /// - Parameters:
    ///   - title: The title of the page.
    ///   - description: The description of the page.
    ///   - keywords: Array of keywords (optional).
    ///   - author: The author of the page (optional).
    ///   - viewport: The viewport meta content (default: "width=device-width, initial-scale=1.0").
    ///   - robots: The robots directive (default: "index, follow").
    /// - Returns: An array of common Meta tags.
    ///
    /// ## Example
    /// ```swift
    /// let commonTags = SEO.common(
    ///     title: "My Page",
    ///     description: "Page description",
    ///     keywords: ["swift", "html", "web"]
    /// )
    /// ```
    public static func common(
        title: String,
        description: String,
        keywords: [String]? = nil,
        author: String? = nil,
        viewport: String = "width=device-width, initial-scale=1.0",
        robots: String = "index, follow"
    ) -> [Meta] {
        var tags = [
            Meta(charset: "UTF-8"),
            Meta(name: "viewport", content: viewport),
            Meta(name: "description", content: description),
            Meta(name: "robots", content: robots)
        ]
        
        if let keywords = keywords, !keywords.isEmpty {
            tags.append(Meta(name: "keywords", content: keywords.joined(separator: ", ")))
        }
        
        if let author = author {
            tags.append(Meta(name: "author", content: author))
        }
        
        return tags
    }
    
    /// Generates a complete set of SEO tags (Common + Open Graph + Twitter).
    ///
    /// - Parameters:
    ///   - title: The title of the page.
    ///   - description: The description of the page.
    ///   - image: The URL of the preview image.
    ///   - url: The canonical URL of the page.
    ///   - keywords: Array of keywords (optional).
    ///   - author: The author of the page (optional).
    ///   - twitterSite: The Twitter username of the website (optional).
    ///   - twitterCreator: The Twitter username of the content creator (optional).
    /// - Returns: An array of all SEO Meta tags.
    public static func complete(
        title: String,
        description: String,
        image: String,
        url: String,
        keywords: [String]? = nil,
        author: String? = nil,
        twitterSite: String? = nil,
        twitterCreator: String? = nil
    ) -> [Meta] {
        var tags: [Meta] = []
        
        tags.append(contentsOf: common(title: title, description: description, keywords: keywords, author: author))
        tags.append(contentsOf: openGraph(title: title, description: description, image: image, url: url))
        tags.append(contentsOf: twitterCard(title: title, description: description, image: image, site: twitterSite, creator: twitterCreator))
        
        return tags
    }
}

