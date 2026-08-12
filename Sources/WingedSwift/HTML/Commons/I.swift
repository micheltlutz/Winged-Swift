import Foundation

/// Represents an <i> HTML tag (typically used for icons or idiomatic text).
public class I: HTMLTag {
    /// Initializes a new <i> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <i> tag.
    ///   - children: The children tags of the <i> tag.
    ///   - content: The content of the <i> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("i", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <i> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// I {
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
