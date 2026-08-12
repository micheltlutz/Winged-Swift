import Foundation

/// Represents a <dd> HTML tag.
///
/// The <dd> tag holds the description of the preceding `Dt` inside a `Dl`.
public class Dd: HTMLTag {
    /// Initializes a new <dd> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <dd> tag.
    ///   - children: The children tags of the <dd> tag.
    ///   - content: The content of the <dd> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("dd", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <dd> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Dd {
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
