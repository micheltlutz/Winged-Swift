import Foundation

/// Represents a <label> HTML tag.
public class Label: HTMLTag {
    /// Initializes a new <label> tag.
    ///
    /// - Parameters:
    ///   - id: The ID of the element this label is for.
    ///   - content: The content of the label element.
    ///   - attributes: Additional attributes of the <label> tag.
    public init(for id: String, content: String? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "for", value: id))
        super.init("label", attributes: allAttributes, content: content)
    }
}
