import Foundation

/// Represents a <figcaption> HTML tag.
///
/// The <figcaption> tag defines a caption for a <figure> element.
public class Figcaption: HTMLTag {
    /// Initializes a new <figcaption> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <figcaption> tag.
    ///   - children: Nested tags inside the <figcaption> tag.
    ///   - content: The content of the <figcaption> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("figcaption", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <figcaption> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Figcaption {
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
