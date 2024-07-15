import Foundation

/// Represents an <option> HTML tag.
public class Option: HTMLTag {
    /// Initializes a new <option> tag.
    ///
    /// - Parameters:
    ///   - value: The value of the option element.
    ///   - content: The content of the option element.
    ///   - attributes: Additional attributes of the <option> tag.
    public init(value: String, content: String? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "value", value: value))
        super.init("option", attributes: allAttributes, content: content)
    }
}
