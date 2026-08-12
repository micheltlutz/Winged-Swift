import Foundation

/// Represents an <ol> HTML tag.
public class Ol: HTMLTag {
    /// Initializes a new <ol> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <ol> tag.
    ///   - children: The children tags of the <ol> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("ol", attributes: attributes, children: children)
    }

    /// Initializes a new <ol> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Ol {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        attributes: [Attribute] = [],
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            attributes: attributes,
            children: children()
        )
    }
}
