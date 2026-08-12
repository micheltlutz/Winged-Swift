import Foundation

/// Represents a <mark> HTML tag.
///
/// The <mark> tag defines marked/highlighted text.
public class Mark: HTMLTag {
    /// Initializes a new <mark> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <mark> tag.
    ///   - children: Nested tags inside the <mark> tag.
    ///   - content: The content of the <mark> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("mark", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <mark> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Mark {
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
