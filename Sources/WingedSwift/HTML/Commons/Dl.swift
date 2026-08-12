import Foundation

/// Represents a <dl> HTML tag.
public class Dl: HTMLTag {
    /// Initializes a new <dl> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <dl> tag.
    ///   - children: The children tags of the <dl> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("dl", attributes: attributes, children: children)
    }

    /// Initializes a new <dl> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Dl {
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
