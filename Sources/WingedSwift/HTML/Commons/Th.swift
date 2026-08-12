import Foundation

/// Represents a <th> HTML tag.
public class Th: HTMLTag {
    /// Initializes a new <th> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <th> tag.
    ///   - children: The children tags of the <th> tag.
    ///   - content: The content of the <th> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("th", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <th> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Th {
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
