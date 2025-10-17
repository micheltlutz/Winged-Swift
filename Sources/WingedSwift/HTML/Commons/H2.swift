import Foundation

/// Represents an <h2> HTML tag.
public class H2: HTMLTag {
    /// Initializes a new <h2> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h2> tag.
    ///   - content: The content of the <h2> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h2", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}
