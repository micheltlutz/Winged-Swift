import Foundation

/// Represents an <em> HTML tag.
public class Em: HTMLTag {
    /// Initializes a new <em> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <em> tag.
    ///   - children: The children tags of the <em> tag.
    ///   - content: The content of the <em> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("em", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
