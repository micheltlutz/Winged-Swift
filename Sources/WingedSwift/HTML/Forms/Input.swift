import Foundation

/// Represents an <input> HTML tag.
public class Input: HTMLTag {
    /// Initializes a new <input> tag.
    ///
    /// - Parameters:
    ///   - type: The type of the input element.
    ///   - name: The name of the input element. Optional when not needed (e.g. search UI).
    ///   - value: The value of the input element.
    ///   - attributes: Additional attributes of the <input> tag.
    public init(type: String, name: String? = nil, value: String? = nil, attributes: [Attribute] = []) {
        var allAttributes: [Attribute] = [Attribute(key: "type", value: type)]
        if let name = name {
            allAttributes.append(Attribute(key: "name", value: name))
        }
        if let value = value {
            allAttributes.append(Attribute(key: "value", value: value))
        }
        allAttributes.append(contentsOf: attributes)
        super.init("input", attributes: allAttributes)
    }
}
