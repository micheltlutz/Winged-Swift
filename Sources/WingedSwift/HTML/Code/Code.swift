import Foundation

/// Represents a <code> HTML tag.
public class Code: HTMLTag {
    /// Initializes a new <code> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <code> tag.
    ///   - children: Nested tags inside the code span.
    ///   - content: The content of the <code> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("code", attributes: attributes, children: children, content: content)
    }

    /// Initializes a new <code> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Code {
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
