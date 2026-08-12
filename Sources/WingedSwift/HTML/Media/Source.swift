import Foundation

/// Represents a <source> HTML tag.
///
/// The <source> tag offers an alternative media file to a `Picture`, `Video` or `Audio` parent.
/// It is a void element.
///
/// ## Example
/// ```swift
/// Picture(children: [
///     Source(srcset: "/img/hero.avif", type: "image/avif"),
///     Source(srcset: "/img/hero.webp", type: "image/webp"),
///     Img(src: "/img/hero.jpg", alt: "Hero")
/// ])
/// ```
public class Source: HTMLTag {
    /// Initializes a new <source> tag.
    ///
    /// - Parameters:
    ///   - src: The media file URL, for `Video` and `Audio` parents (optional).
    ///   - srcset: The candidate image URLs, for a `Picture` parent (optional).
    ///   - type: The MIME type of the resource (optional).
    ///   - media: The media query the source applies to (optional).
    ///   - attributes: Additional attributes of the <source> tag.
    public init(
        src: String? = nil,
        srcset: String? = nil,
        type: String? = nil,
        media: String? = nil,
        attributes: [Attribute] = []
    ) {
        var allAttributes = attributes
        if let src = src {
            allAttributes.append(Attribute(key: "src", value: src))
        }
        if let srcset = srcset {
            allAttributes.append(Attribute(key: "srcset", value: srcset))
        }
        if let type = type {
            allAttributes.append(Attribute(key: "type", value: type))
        }
        if let media = media {
            allAttributes.append(Attribute(key: "media", value: media))
        }
        super.init("source", attributes: allAttributes)
    }
}
