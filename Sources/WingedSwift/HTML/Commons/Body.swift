import Foundation

/// Represents a <body> HTML tag.
public class Body: HTMLTag {
    /// Initializes a new <body> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <body> tag.
    ///   - children: The children tags of the <body> tag.
    ///   - content: The content of the <body> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("body", attributes: attributes, children: children, content: content)
    }
}
