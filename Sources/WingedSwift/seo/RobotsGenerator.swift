import Foundation

/// One group of `robots.txt` rules for a user agent.
public struct RobotsRule: Sendable, Equatable {
    /// The crawler the rule applies to; `*` for all.
    public var userAgent: String
    /// Paths the crawler may fetch.
    public var allow: [String]
    /// Paths the crawler must not fetch.
    public var disallow: [String]

    /// Creates a rule.
    ///
    /// - Parameters:
    ///   - userAgent: The crawler name, or `*`.
    ///   - allow: Allowed path prefixes.
    ///   - disallow: Disallowed path prefixes.
    public init(userAgent: String = "*", allow: [String] = ["/"], disallow: [String] = []) {
        self.userAgent = userAgent
        self.allow = allow
        self.disallow = disallow
    }

    /// Allows every crawler everywhere.
    public static let allowAll = RobotsRule()
}

/// Writes `robots.txt`.
///
/// ## Example
/// ```swift
/// RobotsGenerator.generate(
///     rules: [RobotsRule(disallow: ["/drafts/"]), RobotsRule(userAgent: "GPTBot", allow: [], disallow: ["/"])],
///     sitemap: "https://example.com/sitemap.xml"
/// )
/// ```
public enum RobotsGenerator {
    /// Renders the rules.
    ///
    /// - Parameters:
    ///   - rules: The rule groups, in order.
    ///   - sitemap: The absolute URL of the sitemap, if any.
    /// - Returns: The `robots.txt` contents, ending with a newline.
    public static func generate(rules: [RobotsRule] = [.allowAll], sitemap: String? = nil) -> String {
        var groups = rules.map { rule in
            var lines = ["User-agent: \(rule.userAgent)"]
            lines += rule.allow.map { "Allow: \($0)" }
            lines += rule.disallow.map { "Disallow: \($0)" }
            return lines.joined(separator: "\n")
        }
        if let sitemap {
            groups.append("Sitemap: \(sitemap)")
        }
        return groups.joined(separator: "\n\n") + "\n"
    }
}
