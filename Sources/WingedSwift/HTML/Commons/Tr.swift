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
}
