import Foundation

/// Represents an <img> HTML tag.
public class Img: HTMLTag {
    /// Initializes a new <img> tag.
    ///
    /// - Parameters:
    ///   - src: The source URL of the image.
    ///   - alt: The alt text of the image.
    ///   - attributes: Additional attributes of the <img> tag.
    public init(src: String, alt: String? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "src", value: src))
        if let altText = alt {
            allAttributes.append(Attribute(key: "alt", value: altText))
        }
        super.init("img", attributes: allAttributes)
    }
}
