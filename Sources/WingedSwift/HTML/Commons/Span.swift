import Foundation

/// Represents a <span> HTML tag.
public class Span: HTMLTag {
    /// Initializes a new <span> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <span> tag.
    ///   - children: The children tags of the <span> tag.
    ///   - content: The content of the <span> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("span", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <span> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Span {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        attributes: [Attribute] = [],
        content: String? = nil,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            attributes: attributes,
            children: children(),
            content: content
        )
    }
}
