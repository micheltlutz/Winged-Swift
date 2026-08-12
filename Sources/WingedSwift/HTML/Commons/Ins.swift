import Foundation

/// Represents a <ins> HTML tag.
///
/// The <ins> tag marks text inserted into the document.
public class Ins: HTMLTag {
    /// Initializes a new <ins> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <ins> tag.
    ///   - children: The children tags of the <ins> tag.
    ///   - content: The content of the <ins> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("ins", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <ins> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Ins {
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
