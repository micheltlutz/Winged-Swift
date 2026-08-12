import Foundation

/// Represents a <dt> HTML tag.
///
/// The <dt> tag holds the term being described inside a `Dl`.
public class Dt: HTMLTag {
    /// Initializes a new <dt> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <dt> tag.
    ///   - children: The children tags of the <dt> tag.
    ///   - content: The content of the <dt> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("dt", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <dt> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Dt {
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
