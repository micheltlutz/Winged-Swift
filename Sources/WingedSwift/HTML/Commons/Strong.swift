import Foundation

/// Represents a <strong> HTML tag.
public class Strong: HTMLTag {
    /// Initializes a new <strong> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <strong> tag.
    ///   - children: The children tags of the <strong> tag.
    ///   - content: The content of the <strong> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("strong", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
