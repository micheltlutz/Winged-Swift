import Foundation

/// Represents a <pre> HTML tag.
public class Pre: HTMLTag {
    /// Initializes a new <pre> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <pre> tag.
    ///   - children: Nested tags inside the block, typically a single `Code`.
    ///   - content: The content of the <pre> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("pre", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <pre> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Pre {
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
