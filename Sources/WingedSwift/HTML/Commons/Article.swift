import Foundation

/// Represents an <article> HTML tag.
///
/// The <article> tag specifies independent, self-contained content.
public class Article: HTMLTag {
    /// Initializes a new <article> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <article> tag.
    ///   - children: The children tags of the <article> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("article", attributes: attributes, children: children)
    }
}

