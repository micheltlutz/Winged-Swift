import Foundation

/// Represents a <p> HTML tag.
public class P: HTMLTag {
    /// Initializes a new <p> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <p> tag.
    ///   - children: The children tags of the <p> tag.
    ///   - content: The content of the <p> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("p", attributes: attributes, children: children, content: content)
    }
}
