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
        let normalised = String(String.UnicodeScalarView(decoded(attribute.value).filter { $0.value > 0x20 }))
            .lowercased()
        return blockedSchemes.contains { normalised.hasPrefix($0) }
    }

    /// Named references that can spell a scheme; letters have no named reference.
    private static let schemeReferences: [String: Unicode.Scalar] = ["colon": ":", "Tab": "\t", "NewLine": "\n"]

    /// The value as the browser reads it: character references decoded once, so an unescaped
    /// `javascript&#58;` or `java&Tab;script:` is caught. Numeric references decode without a
    /// trailing `;`, as browsers do.
    static func decoded(_ value: String) -> [Unicode.Scalar] {
        let scalars = Array(value.unicodeScalars)
        var result: [Unicode.Scalar] = []
        var index = 0
        while index < scalars.count {
            guard scalars[index] == "&", index + 1 < scalars.count else {
                result.append(scalars[index])
                index += 1
                continue
            }
            if let (scalar, next) = numericReference(scalars, at: index + 1)
                ?? namedReference(scalars, at: index + 1) {
                result.append(scalar)
                index = next
            } else {
                result.append(scalars[index])
                index += 1
            }
        }
        return result
    }

    /// `#58`, `#x3A`, with an optional `;`, starting after the `&`.
    private static func numericReference(_ scalars: [Unicode.Scalar], at start: Int) -> (Unicode.Scalar, Int)? {
        guard scalars[start] == "#" else { return nil }
        var index = start + 1
        let isHex = index < scalars.count && (scalars[index] == "x" || scalars[index] == "X")
        if isHex { index += 1 }
        let digitsStart = index
        var code: UInt32 = 0
        while index < scalars.count, let digit = Int(String(scalars[index]), radix: isHex ? 16 : 10) {
            code = min(code &* (isHex ? 16 : 10) &+ UInt32(digit), 0x110000)
            index += 1
        }
        guard index > digitsStart else { return nil }
        if index < scalars.count, scalars[index] == ";" { index += 1 }
        return (Unicode.Scalar(code) ?? "\u{FFFD}", index)
    }

    /// `colon;`, `Tab;`, `NewLine;` — case-sensitive and with the `;`, as the spec requires.
    private static func namedReference(_ scalars: [Unicode.Scalar], at start: Int) -> (Unicode.Scalar, Int)? {
        guard let semicolon = scalars[start...].prefix(8).firstIndex(of: ";"),
              let scalar = schemeReferences[String(String.UnicodeScalarView(scalars[start..<semicolon]))] else {
            return nil
        }
        return (scalar, semicolon + 1)
    }
}
