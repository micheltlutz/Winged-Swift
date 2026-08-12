import Foundation

/// Represents an <article> HTML tag.
///
/// The <article> tag specifies independent, self-contained content.
public class Article: HTMLTag {
    /// Initializes a new <article> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <article> tag.
    ///   - children: The children tags of the <article> tag.
    ///   - content: The text content of the <article> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("article", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <article> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Article {
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
