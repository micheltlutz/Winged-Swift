import Foundation

/// Represents a <div> HTML tag.
public class Div: HTMLTag {
    /// Initializes a new <div> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <div> tag.
    ///   - children: The children tags of the <div> tag.
    ///   - content: The content of the <div> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("div", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <div> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Div {
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
