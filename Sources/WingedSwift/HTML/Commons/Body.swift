import Foundation

/// Represents a <body> HTML tag.
public class Body: HTMLTag {
    /// Initializes a new <body> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <body> tag.
    ///   - children: The children tags of the <body> tag.
    ///   - content: The content of the <body> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("body", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <body> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Body {
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
