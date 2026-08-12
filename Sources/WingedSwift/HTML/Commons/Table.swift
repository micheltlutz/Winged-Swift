import Foundation

/// Represents a <table> HTML tag.
public class Table: HTMLTag {
    /// Initializes a new <table> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <table> tag.
    ///   - children: The children tags of the <table> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("table", attributes: attributes, children: children)
    }

    /// Initializes a new <table> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Table {
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
