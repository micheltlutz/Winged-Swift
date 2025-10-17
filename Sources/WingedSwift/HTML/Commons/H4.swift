import Foundation

/// Represents an <h4> HTML tag.
public class H4: HTMLTag {
    /// Initializes a new <h4> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h4> tag.
    ///   - content: The content of the <h4> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h4", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}
