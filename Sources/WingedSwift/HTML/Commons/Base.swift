import Foundation

/// Represents a <base> HTML tag.
///
/// The <base> tag sets the base URL for every relative URL in the document.
/// It is a void element and must appear inside `Head`.
public class Base: HTMLTag {
    /// Initializes a new <base> tag.
    ///
    /// - Parameters:
    ///   - href: The base URL for relative URLs in the document.
    ///   - target: The default browsing context for links and forms (optional).
    ///   - attributes: Additional attributes of the <base> tag.
    public init(href: String, target: String? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "href", value: href))
        if let target = target {
            allAttributes.append(Attribute(key: "target", value: target))
        }
        super.init("base", attributes: allAttributes)
    }
}
