import Foundation

/// Represents an <h4> HTML tag.
public class H4: HTMLTag {
    /// Initializes a new <h4> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <h4> tag.
    ///   - children: Nested tags inside the heading (e.g. `A`).
    ///   - content: The content of the <h4> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("h4", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
