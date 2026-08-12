import Foundation

/// Represents a <address> HTML tag.
///
/// The <address> tag provides contact information for its nearest article or body ancestor.
public class Address: HTMLTag {
    /// Initializes a new <address> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <address> tag.
    ///   - children: The children tags of the <address> tag.
    ///   - content: The content of the <address> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("address", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <address> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Address {
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
