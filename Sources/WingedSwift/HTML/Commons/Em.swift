import Foundation

/// Represents an <em> HTML tag.
public class Em: HTMLTag {
    /// Initializes a new <em> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <em> tag.
    ///   - children: The children tags of the <em> tag.
    ///   - content: The content of the <em> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("em", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <em> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Em {
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
