import Foundation

/// Represents an <aside> HTML tag.
///
/// The <aside> tag defines content aside from the content it is placed in.
public class Aside: HTMLTag {
    /// Initializes a new <aside> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <aside> tag.
    ///   - children: The children tags of the <aside> tag.
    ///   - content: The text content of the <aside> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("aside", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <aside> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Aside {
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
