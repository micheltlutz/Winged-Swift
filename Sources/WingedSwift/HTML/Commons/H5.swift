import Foundation

/// Represents an <h5> HTML tag.
public class H5: HTMLTag {
    /// Initializes a new <h5> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h5> tag.
    ///   - content: The content of the <h5> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h5", attributes: attributes, content: content, escapeContent: escapeContent)
    }
}

