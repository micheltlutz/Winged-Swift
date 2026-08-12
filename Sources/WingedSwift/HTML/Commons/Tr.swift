import Foundation

/// Represents a <tr> HTML tag.
public class Tr: HTMLTag {
    /// Initializes a new <tr> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <tr> tag.
    ///   - children: The children tags of the <tr> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("tr", attributes: attributes, children: children)
    }

    /// Initializes a new <tr> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Tr {
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
