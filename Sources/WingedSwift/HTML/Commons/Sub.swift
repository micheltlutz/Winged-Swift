import Foundation

/// Represents a <sub> HTML tag.
///
/// The <sub> tag renders subscript text.
public class Sub: HTMLTag {
    /// Initializes a new <sub> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <sub> tag.
    ///   - children: The children tags of the <sub> tag.
    ///   - content: The content of the <sub> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("sub", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <sub> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Sub {
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
