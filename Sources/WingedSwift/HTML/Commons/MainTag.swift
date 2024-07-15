import Foundation

/// Represents a <main> HTML tag.
public class MainTag: HTMLTag {
    /// Initializes a new <main> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <main> tag.
    ///   - children: The children tags of the <main> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("main", attributes: attributes, children: children)
    }
}
