import Foundation

/// Represents a <link> HTML tag.
public class Link: HTMLTag {
    /// Initializes a new <link> tag.
    ///
    /// - Parameters:
    ///   - href: The URL of the link.
    ///   - rel: The relationship between the current document and the linked document.
    ///   - attributes: Additional attributes of the <link> tag.
    public init(href: String, rel: String, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "href", value: href))
        allAttributes.append(Attribute(key: "rel", value: rel))
        super.init("link", attributes: allAttributes)
    }
}
