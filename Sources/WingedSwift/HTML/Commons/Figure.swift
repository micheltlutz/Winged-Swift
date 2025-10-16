import Foundation

/// Represents a <figure> HTML tag.
///
/// The <figure> tag specifies self-contained content, like illustrations, diagrams, photos, code listings, etc.
public class Figure: HTMLTag {
    /// Initializes a new <figure> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <figure> tag.
    ///   - children: The children tags of the <figure> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("figure", attributes: attributes, children: children)
    }
}

