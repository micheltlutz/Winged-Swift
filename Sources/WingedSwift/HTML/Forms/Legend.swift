import Foundation

/// Represents a <legend> HTML tag.
///
/// The <legend> tag captions a `Fieldset`; it must be the fieldset's first child.
public class Legend: HTMLTag {
    /// Initializes a new <legend> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <legend> tag.
    ///   - children: The children tags of the <legend> tag.
    ///   - content: The content of the <legend> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("legend", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <legend> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Legend {
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
