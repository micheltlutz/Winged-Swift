import Foundation

/// Represents a <section> HTML tag.
public class Section: HTMLTag {
    /// Initializes a new <section> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <section> tag.
    ///   - children: The children tags of the <section> tag.
    ///   - content: The content of the <section> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("section", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }
}
