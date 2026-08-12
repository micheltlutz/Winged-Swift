import Foundation

/// Represents a <header> HTML tag.
public class Header: HTMLTag {
    /// Initializes a new <header> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <header> tag.
    ///   - children: The children tags of the <header> tag.
    ///   - content: The text content of the <header> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("header", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <header> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Header {
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
