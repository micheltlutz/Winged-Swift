import Foundation

/// Represents a <output> HTML tag.
///
/// The <output> tag displays the result of a calculation or user action.
public class Output: HTMLTag {
    /// Initializes a new <output> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <output> tag.
    ///   - children: The children tags of the <output> tag.
    ///   - content: The content of the <output> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("output", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <output> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Output {
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
