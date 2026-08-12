import Foundation

/// Represents a <blockquote> HTML tag.
///
/// The <blockquote> tag marks a section quoted from another source.
public class Blockquote: HTMLTag {
    /// Initializes a new <blockquote> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <blockquote> tag.
    ///   - children: The children tags of the <blockquote> tag.
    ///   - content: The content of the <blockquote> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("blockquote", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <blockquote> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Blockquote {
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
