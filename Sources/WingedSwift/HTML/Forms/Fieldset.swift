import Foundation

/// Represents a <fieldset> HTML tag.
public class Fieldset: HTMLTag {
    /// Initializes a new <fieldset> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <fieldset> tag.
    ///   - children: The children tags of the <fieldset> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("fieldset", attributes: attributes, children: children)
    }
}
