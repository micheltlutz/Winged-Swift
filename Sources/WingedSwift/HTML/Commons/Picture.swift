import Foundation

/// Represents a <picture> HTML tag.
///
/// The <picture> tag wraps `Source` alternatives and a fallback `Img` for art direction.
public class Picture: HTMLTag {
    /// Initializes a new <picture> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <picture> tag.
    ///   - children: The children tags of the <picture> tag.
    ///   - content: The content of the <picture> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("picture", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <picture> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Picture {
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
