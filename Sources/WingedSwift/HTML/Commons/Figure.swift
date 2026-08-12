import Foundation

/// Represents a <figure> HTML tag.
///
/// The <figure> tag specifies self-contained content, like illustrations, diagrams, photos, code listings, etc.
public class Figure: HTMLTag {
    /// Initializes a new <figure> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <figure> tag.
    ///   - children: The children tags of the <figure> tag.
    ///   - content: The text content of the <figure> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("figure", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <figure> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Figure {
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
