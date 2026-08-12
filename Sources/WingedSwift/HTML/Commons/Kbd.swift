import Foundation

/// Represents a <kbd> HTML tag.
///
/// The <kbd> tag marks keyboard input.
public class Kbd: HTMLTag {
    /// Initializes a new <kbd> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <kbd> tag.
    ///   - children: The children tags of the <kbd> tag.
    ///   - content: The content of the <kbd> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("kbd", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <kbd> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Kbd {
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
