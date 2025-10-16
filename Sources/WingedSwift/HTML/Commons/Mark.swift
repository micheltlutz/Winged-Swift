import Foundation

/// Represents a <mark> HTML tag.
///
/// The <mark> tag defines marked/highlighted text.
public class Mark: HTMLTag {
    /// Initializes a new <mark> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <mark> tag.
    ///   - content: The content of the <mark> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("mark", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}

