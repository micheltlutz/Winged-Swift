import Foundation

/// Represents a <small> HTML tag.
public class Small: HTMLTag {
    /// Initializes a new <small> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <small> tag.
    ///   - children: The children tags of the <small> tag.
    ///   - content: The content of the <small> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("small", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <small> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Small {
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
