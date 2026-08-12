import Foundation

/// Represents a <strong> HTML tag.
public class Strong: HTMLTag {
    /// Initializes a new <strong> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <strong> tag.
    ///   - children: The children tags of the <strong> tag.
    ///   - content: The content of the <strong> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("strong", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <strong> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Strong {
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
