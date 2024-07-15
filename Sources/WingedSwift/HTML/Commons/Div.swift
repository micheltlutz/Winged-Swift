import Foundation

/// Represents a <div> HTML tag.
public class Div: HTMLTag {
    /// Initializes a new <div> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <div> tag.
    ///   - children: The children tags of the <div> tag.
    ///   - content: The content of the <div> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("div", attributes: attributes, children: children, content: content)
    }
}
