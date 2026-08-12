import Foundation

/// Represents a <del> HTML tag.
///
/// The <del> tag marks text removed from the document.
public class Del: HTMLTag {
    /// Initializes a new <del> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <del> tag.
    ///   - children: The children tags of the <del> tag.
    ///   - content: The content of the <del> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("del", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <del> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Del {
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
