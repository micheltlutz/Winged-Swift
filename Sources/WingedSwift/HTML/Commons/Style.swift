import Foundation

/// Represents a <style> HTML tag.
///
/// CSS is never escaped, mirroring `Script`: escaping would corrupt selectors such as `a > b`.
/// Only embed stylesheets you control.
public class Style: HTMLTag {
    /// Initializes a new <style> tag.
    ///
    /// - Parameters:
    ///   - media: The media query the stylesheet applies to (optional).
    ///   - attributes: Additional attributes of the <style> tag.
    ///   - content: The CSS source.
    ///   - escapeContent: If true, escapes HTML special characters. Default is false for style tags.
    public init(
        media: String? = nil,
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = false
    ) {
        var allAttributes = attributes
        if let media = media {
            allAttributes.append(Attribute(key: "media", value: media))
        }
        super.init("style", attributes: allAttributes, content: content, escapeContent: escapeContent)
    }
}
