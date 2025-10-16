import Foundation

/// Represents an <script> HTML tag.
public class Script: HTMLTag {
    /// Initializes a new <script> tag.
    ///
    /// - Parameters:
    ///   - type: The typeof script default is `text/javascript`.
    ///   - attributes: Additional attributes of the <script> tag.
    ///   - content: The content of the <script> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is false for script tags.
    public init(type: String = "text/javascript", attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = false) {
        var allAttributes = attributes

        allAttributes.append(Attribute(key: "type", value: type, escape: false))
        super.init("script", attributes: allAttributes, content: content, escapeContent: escapeContent)
    }
}
