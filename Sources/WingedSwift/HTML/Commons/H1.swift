import Foundation

/// Represents an <h1> HTML tag.
///
/// The <h1> tag defines the most important heading.
public class H1: HTMLTag {
    /// Initializes a new <h1> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h1> tag.
    ///   - content: The content of the <h1> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h1", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}
