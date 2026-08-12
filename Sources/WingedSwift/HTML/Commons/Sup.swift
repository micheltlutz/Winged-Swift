import Foundation

/// Represents a <sup> HTML tag.
///
/// The <sup> tag renders superscript text.
public class Sup: HTMLTag {
    /// Initializes a new <sup> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <sup> tag.
    ///   - children: The children tags of the <sup> tag.
    ///   - content: The content of the <sup> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("sup", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <sup> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Sup {
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
