import Foundation

/// Represents an <h3> HTML tag.
public class H3: HTMLTag {
    /// Initializes a new <h3> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h3> tag.
    ///   - children: Nested tags inside the heading (e.g. `A`).
    ///   - content: The content of the <h3> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h3", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
