import Foundation

/// Represents an <h6> HTML tag.
public class H6: HTMLTag {
    /// Initializes a new <h6> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h6> tag.
    ///   - children: Nested tags inside the heading (e.g. `A`).
    ///   - content: The content of the <h6> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h6", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <h6> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// H6 {
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
