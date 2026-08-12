import Foundation

/// Represents a <tfoot> HTML tag.
///
/// The <tfoot> tag groups the footer rows of a `Table`.
public class Tfoot: HTMLTag {
    /// Initializes a new <tfoot> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <tfoot> tag.
    ///   - children: The children tags of the <tfoot> tag.
    ///   - content: The content of the <tfoot> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("tfoot", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <tfoot> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Tfoot {
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
