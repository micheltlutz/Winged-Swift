import Foundation

/// Represents a <footer> HTML tag.
public class Footer: HTMLTag {
    /// Initializes a new <footer> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <footer> tag.
    ///   - children: The children tags of the <footer> tag.
    ///   - content: The text content of the <footer> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("footer", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <footer> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Footer {
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
