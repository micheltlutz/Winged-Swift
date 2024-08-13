import Foundation

/// Represents an <script> HTML tag.
public class Script: HTMLTag {
    /// Initializes a new <script> tag.
    ///
    /// - Parameters:
    ///   - type: The typeof script default is `text/javascript`.
    ///   - attributes: Additional attributes of the <script> tag.
    ///   - content: The content of the <script> tag.
    public init(type: String = "text/javascript", attributes: [Attribute] = [], content: String? = nil) {
        var allAttributes = attributes

        allAttributes.append(Attribute(key: "type", value: type))
        super.init("script", attributes: allAttributes, content: content)
    }
}
