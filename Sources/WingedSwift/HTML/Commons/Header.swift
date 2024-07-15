import Foundation

/// Represents a <header> HTML tag.
public class Header: HTMLTag {
    /// Initializes a new <header> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <header> tag.
    ///   - children: The children tags of the <header> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("header", attributes: attributes, children: children)
    }
}
