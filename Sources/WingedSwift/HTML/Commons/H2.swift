import Foundation

/// Represents an <h2> HTML tag.
public class H2: HTMLTag {
    /// Initializes a new <h2> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h2> tag.
    ///   - children: Nested tags inside the heading (e.g. `A`).
    ///   - content: The content of the <h2> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h2", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
