import Foundation

/// Represents an <h6> HTML tag.
public class H6: HTMLTag {
    /// Initializes a new <h6> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h6> tag.
    ///   - content: The content of the <h6> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h6", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}

