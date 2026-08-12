import Foundation

/// Represents a <main> HTML tag.
public class MainTag: HTMLTag {
    /// Initializes a new <main> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <main> tag.
    ///   - children: The children tags of the <main> tag.
    ///   - content: The text content of the <main> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("main", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <main> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// MainTag {
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
