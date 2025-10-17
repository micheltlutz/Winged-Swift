import Foundation

/// Represents a <figcaption> HTML tag.
///
/// The <figcaption> tag defines a caption for a <figure> element.
public class Figcaption: HTMLTag {
    /// Initializes a new <figcaption> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <figcaption> tag.
    ///   - content: The content of the <figcaption> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("figcaption", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}
