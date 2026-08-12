import Foundation

/// Represents a <select> HTML tag.
public class Select: HTMLTag {
    /// Initializes a new <select> tag.
    ///
    /// - Parameters:
    ///   - name: The name of the select element.
    ///   - children: The option tags of the <select> tag.
    ///   - attributes: Additional attributes of the <select> tag.
    public init(name: String, children: [HTMLTag] = [], attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "name", value: name))
        super.init("select", attributes: allAttributes, children: children)
    }

    /// Initializes a new <select> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Select(name: "…") {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        name: String,
        attributes: [Attribute] = [],
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            name: name,
            children: children(),
            attributes: attributes
        )
    }
}
