import Foundation

/// Represents a <select> HTML tag.
public class Select: HTMLTag {
    /// Initializes a new <select> tag.
    ///
    /// - Parameters:
    ///   - name: The name of the select element.
    ///   - children: The option tags of the <select> tag.
    ///   - attributes: Additional attributes of the <select> tag.
    public init(name: String, children: [HTMLTag] = [], attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "name", value: name))
        super.init("select", attributes: allAttributes, children: children)
    }
}
