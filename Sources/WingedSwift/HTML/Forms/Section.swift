import Foundation

/// Represents a <section> HTML tag.
public class Section: HTMLTag {
    /// Initializes a new <section> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <section> tag.
    ///   - children: The children tags of the <section> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("section", attributes: attributes, children: children)
    }
}
