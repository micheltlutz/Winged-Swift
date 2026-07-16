import Foundation

/// Represents an <a> HTML tag.
public class A: HTMLTag {
    /// Initializes a new <a> tag.
    ///
    /// - Parameters:
    ///   - href: The URL the link points to.
    ///   - attributes: Additional attributes of the <a> tag.
    ///   - children: Nested tags inside the link (e.g. `Img`, `I`, `Span`).
    ///   - content: Text content of the <a> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(
        href: String,
        attributes: [Attribute] = [],
        children: [HTMLTag] = [],
        content: String? = nil,
        escapeContent: Bool = true
    ) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "href", value: href))
        super.init("a", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }
}
