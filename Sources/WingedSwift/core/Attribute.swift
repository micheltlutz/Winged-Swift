import Foundation

/// Represents an HTML attribute with a key and a value.
public struct Attribute: Sendable {
    let key: String
    let value: String
    /// When true, the attribute renders as ` key` with no `="value"` (e.g. `hidden`, `checked`).
    let isBoolean: Bool
    /// When true, a URL attribute is rendered as given, skipping the script-URL check.
    var isTrustedURL = false

    /// Initializes a new HTML attribute.
    ///
    /// - Parameters:
    ///   - key: The attribute name.
    ///   - value: The attribute value.
    ///   - escape: If true, escapes HTML special characters in the value. Default is true for security.
    public init(key: String, value: String, escape: Bool = true) {
        self.key = key
        self.value = escape ? HTMLEscape.escapeAttribute(value) : value
        self.isBoolean = false
    }

    private init(booleanKey: String) {
        self.key = booleanKey
        self.value = ""
        self.isBoolean = true
    }

    /// Creates a boolean HTML attribute that renders only the key (e.g. `disabled`, `required`).
    ///
    /// - Parameter key: The attribute name.
    /// - Returns: A boolean attribute instance.
    public static func boolean(_ key: String) -> Attribute {
        Attribute(booleanKey: key)
    }

    /// A URL attribute rendered exactly as given, even if it is a `javascript:` URL.
    ///
    /// URL attributes (`href`, `src`, `action`, …) whose value would run script are rendered as
    /// `#` by default. Use this only for a value you wrote yourself — never for data.
    ///
    /// - Parameters:
    ///   - key: The attribute name, such as `"href"`.
    ///   - value: The URL. It is still HTML-escaped.
    /// - Returns: The attribute.
    ///
    /// ## Example
    /// ```swift
    /// HTMLTag("a", attributes: [.trustedURL(key: "href", value: "javascript:print()")], content: "Print")
    /// // or, on any tag:
    /// A(href: "#", content: "Print").trustedURL("href", "javascript:print()")
    /// ```
    public static func trustedURL(key: String, value: String) -> Attribute {
        var attribute = Attribute(key: key, value: value)
        attribute.isTrustedURL = true
        return attribute
    }
}

/// Keeps script URLs out of URL attributes.
///
/// Browsers ignore tabs, newlines and other control characters inside a URL scheme and match it
/// case-insensitively, so `JaVa\tScript:` runs too. The check normalises the same way.
enum URLPolicy {
    /// Attributes whose value is navigated to or fetched.
    static let urlAttributes: Set<String> = [
        "href", "src", "action", "formaction", "poster", "cite", "background", "xlink:href", "data"
    ]

    static let blockedSchemes = ["javascript:", "vbscript:", "data:text/html"]

    /// What gets rendered instead of a blocked URL.
    static let replacement = "#"

    static func isBlocked(_ attribute: Attribute) -> Bool {
        guard !attribute.isTrustedURL, !attribute.isBoolean,
              urlAttributes.contains(attribute.key.lowercased()) else { return false }
        let normalised = String(String.UnicodeScalarView(attribute.value.unicodeScalars.filter { $0.value > 0x20 }))
            .lowercased()
        return blockedSchemes.contains { normalised.hasPrefix($0) }
    }
}
