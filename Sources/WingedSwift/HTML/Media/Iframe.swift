import Foundation

/// Represents an <iframe> HTML tag.
///
/// `title` is required by the initializer on purpose: an untitled iframe is an
/// accessibility failure (WCAG 4.1.2).
public class Iframe: HTMLTag {
    /// Initializes a new <iframe> tag.
    ///
    /// - Parameters:
    ///   - src: The URL of the embedded page.
    ///   - title: The accessible name of the frame, announced by screen readers.
    ///   - loading: The loading strategy (`lazy` or `eager`). Defaults to `"lazy"`.
    ///   - allowfullscreen: If true, renders the boolean `allowfullscreen` attribute.
    ///   - attributes: Additional attributes of the <iframe> tag.
    public init(
        src: String,
        title: String,
        loading: String? = "lazy",
        allowfullscreen: Bool = false,
        attributes: [Attribute] = []
    ) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "src", value: src))
        allAttributes.append(Attribute(key: "title", value: title))
        if let loading = loading {
            allAttributes.append(Attribute(key: "loading", value: loading))
        }
        if allowfullscreen {
            allAttributes.append(.boolean("allowfullscreen"))
        }
        super.init("iframe", attributes: allAttributes)
    }
}
