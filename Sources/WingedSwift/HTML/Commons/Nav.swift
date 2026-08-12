import Foundation

/// Represents a <nav> HTML tag.
public class Nav: HTMLTag {
    /// Initializes a new <nav> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <nav> tag.
    ///   - children: The children tags of the <nav> tag.
    ///   - content: The text content of the <nav> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("nav", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <nav> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Nav {
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
