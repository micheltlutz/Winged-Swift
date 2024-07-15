import Foundation

/// Represents an <embed> HTML tag.
public class Embed: HTMLTag {
    /// Initializes a new <embed> tag.
    ///
    /// - Parameters:
    ///   - src: The source URL of the embed element.
    ///   - type: The type of the embed element.
    ///   - attributes: Additional attributes of the <embed> tag.
    public init(src: String, type: String, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "src", value: src))
        allAttributes.append(Attribute(key: "type", value: type))
        super.init("embed", attributes: allAttributes)
    }
}
