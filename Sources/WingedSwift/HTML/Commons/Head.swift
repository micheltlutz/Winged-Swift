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
}
