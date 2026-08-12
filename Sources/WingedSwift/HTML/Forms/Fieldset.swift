import Foundation

/// Represents a <fieldset> HTML tag.
public class Fieldset: HTMLTag {
    /// Initializes a new <fieldset> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <fieldset> tag.
    ///   - children: The children tags of the <fieldset> tag.
    ///   - content: The text content of the <fieldset> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("fieldset", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <fieldset> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Fieldset {
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
