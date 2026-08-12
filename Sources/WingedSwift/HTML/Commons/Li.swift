import Foundation

/// Represents a <li> HTML tag.
public class Li: HTMLTag {
    /// Initializes a new <li> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <li> tag.
    ///   - children: The children tags of the <li> tag.
    ///   - content: The content of the <li> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("li", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <li> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Li {
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
