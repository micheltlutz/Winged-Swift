import Foundation

/// Represents a <small> HTML tag.
public class Small: HTMLTag {
    /// Initializes a new <small> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <small> tag.
    ///   - children: The children tags of the <small> tag.
    ///   - content: The content of the <small> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("small", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
