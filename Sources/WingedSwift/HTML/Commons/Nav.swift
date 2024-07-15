import Foundation

/// Represents a <nav> HTML tag.
public class Nav: HTMLTag {
    /// Initializes a new <nav> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <nav> tag.
    ///   - children: The children tags of the <nav> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("nav", attributes: attributes, children: children)
    }
}
