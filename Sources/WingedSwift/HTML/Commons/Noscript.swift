import Foundation

/// Represents a <noscript> HTML tag.
///
/// The <noscript> tag holds the fallback shown when scripting is unavailable.
public class Noscript: HTMLTag {
    /// Initializes a new <noscript> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <noscript> tag.
    ///   - children: The children tags of the <noscript> tag.
    ///   - content: The content of the <noscript> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("noscript", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <noscript> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Noscript {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
