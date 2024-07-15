import Foundation

/// Represents an <ol> HTML tag.
public class Ol: HTMLTag {
    /// Initializes a new <ol> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <ol> tag.
    ///   - children: The children tags of the <ol> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("ol", attributes: attributes, children: children)
    }
}
