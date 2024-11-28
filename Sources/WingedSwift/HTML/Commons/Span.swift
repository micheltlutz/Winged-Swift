import Foundation

/// Represents a <span> HTML tag.
public class Span: HTMLTag {
    /// Initializes a new <span> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <span> tag.
    ///   - children: The children tags of the <span> tag.
    ///   - content: The content of the <span> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("span", attributes: attributes, children: children, content: content)
    }
}
