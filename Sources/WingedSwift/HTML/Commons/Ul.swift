import Foundation

/// Represents a <ul> HTML tag.
public class Ul: HTMLTag {
    /// Initializes a new <ul> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <ul> tag.
    ///   - children: The children tags of the <ul> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("ul", attributes: attributes, children: children)
    }

    /// Initializes a new <ul> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Ul {
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
