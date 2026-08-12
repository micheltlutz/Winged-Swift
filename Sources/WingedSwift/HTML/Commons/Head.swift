import Foundation

/// Represents a <head> HTML tag.
public class Head: HTMLTag {
    /// Initializes a new <head> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <head> tag.
    ///   - children: The children tags of the <head> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("head", attributes: attributes, children: children)
    }

    /// Initializes a new <head> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Head {
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
