import Foundation

/// Represents a <li> HTML tag.
public class Li: HTMLTag {
    /// Initializes a new <li> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <li> tag.
    ///   - children: The children tags of the <li> tag.
    ///   - content: The content of the <li> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("li", attributes: attributes, children: children, content: content)
    }
}
