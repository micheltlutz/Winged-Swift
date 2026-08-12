import Foundation

/// Represents an <h2> HTML tag.
public class H2: HTMLTag {
    /// Initializes a new <h2> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h2> tag.
    ///   - children: Nested tags inside the heading (e.g. `A`).
    ///   - content: The content of the <h2> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h2", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <h2> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// H2 {
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
