import Foundation

/// Represents an <i> HTML tag (typically used for icons or idiomatic text).
public class I: HTMLTag {
    /// Initializes a new <i> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <i> tag.
    ///   - children: The children tags of the <i> tag.
    ///   - content: The content of the <i> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("i", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
