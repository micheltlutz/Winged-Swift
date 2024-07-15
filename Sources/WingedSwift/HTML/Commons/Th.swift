import Foundation

/// Represents a <th> HTML tag.
public class Th: HTMLTag {
    /// Initializes a new <th> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <th> tag.
    ///   - children: The children tags of the <th> tag.
    ///   - content: The content of the <th> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("th", attributes: attributes, children: children, content: content)
    }
}
