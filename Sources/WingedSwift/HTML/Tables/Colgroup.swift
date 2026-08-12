import Foundation

/// Represents a <colgroup> HTML tag.
///
/// The <colgroup> tag groups `Col` elements that style a table's columns.
public class Colgroup: HTMLTag {
    /// Initializes a new <colgroup> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <colgroup> tag.
    ///   - children: The children tags of the <colgroup> tag.
    ///   - content: The content of the <colgroup> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("colgroup", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <colgroup> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Colgroup {
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
