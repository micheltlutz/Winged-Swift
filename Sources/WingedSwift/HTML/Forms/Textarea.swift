import Foundation

/// Represents a <textarea> HTML tag.
public class Textarea: HTMLTag {
    /// Initializes a new <textarea> tag.
    ///
    /// - Parameters:
    ///   - name: The name of the textarea element.
    ///   - content: The content of the textarea element.
    ///   - attributes: Additional attributes of the <textarea> tag.
    public init(name: String, content: String? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "name", value: name))
        super.init("textarea", attributes: allAttributes, content: content)
    }
}
