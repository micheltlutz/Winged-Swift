import Foundation

/// Represents a <caption> HTML tag.
///
/// The <caption> tag titles a `Table`; it must be the table's first child.
public class Caption: HTMLTag {
    /// Initializes a new <caption> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <caption> tag.
    ///   - children: The children tags of the <caption> tag.
    ///   - content: The content of the <caption> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("caption", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <caption> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Caption {
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
