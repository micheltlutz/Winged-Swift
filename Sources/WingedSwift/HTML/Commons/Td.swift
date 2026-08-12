import Foundation

/// Represents a <td> HTML tag.
public class Td: HTMLTag {
    /// Initializes a new <td> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <td> tag.
    ///   - children: The children tags of the <td> tag.
    ///   - content: The content of the <td> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("td", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <td> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Td {
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
