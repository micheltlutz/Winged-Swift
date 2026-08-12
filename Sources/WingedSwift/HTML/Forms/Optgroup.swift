import Foundation

/// Represents an <optgroup> HTML tag.
///
/// The <optgroup> tag groups related `Option` elements inside a `Select`.
public class Optgroup: HTMLTag {
    /// Initializes a new <optgroup> tag.
    ///
    /// - Parameters:
    ///   - label: The group label shown to the user.
    ///   - children: The `Option` tags of the group.
    ///   - attributes: Additional attributes of the <optgroup> tag.
    public init(label: String, children: [HTMLTag] = [], attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "label", value: label))
        super.init("optgroup", attributes: allAttributes, children: children)
    }

    /// Initializes a new <optgroup> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Optgroup(label: "…") {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        label: String,
        attributes: [Attribute] = [],
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            label: label,
            children: children(),
            attributes: attributes
        )
    }
}
