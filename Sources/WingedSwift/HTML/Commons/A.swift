import Foundation

/// Represents an <a> HTML tag.
public class A: HTMLTag {
    /// Initializes a new <a> tag.
    ///
    /// - Parameters:
    ///   - href: The URL the link points to.
    ///   - attributes: Additional attributes of the <a> tag.
    ///   - content: The content of the <a> tag.
    public init(href: String, attributes: [Attribute] = [], content: String? = nil) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "href", value: href))
        super.init("a", attributes: allAttributes, content: content)
    }
}
