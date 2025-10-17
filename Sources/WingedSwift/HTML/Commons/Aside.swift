import Foundation

/// Represents an <aside> HTML tag.
///
/// The <aside> tag defines content aside from the content it is placed in.
public class Aside: HTMLTag {
    /// Initializes a new <aside> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <aside> tag.
    ///   - children: The children tags of the <aside> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("aside", attributes: attributes, children: children)
    }
}
