import Foundation

/// Represents a <meta> HTML tag.
public class Meta: HTMLTag {
    /// Initializes a new <meta> tag.
    ///
    /// - Parameters:
    ///   - name: The name of the metadata.
    ///   - content: The value of the metadata.
    ///   - attributes: Additional attributes of the <meta> tag.
    public init(name: String, content: String, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "name", value: name))
        allAttributes.append(Attribute(key: "content", value: content))
        super.init("meta", attributes: allAttributes)
    }
    
    /// Initializes a new <meta> tag.
    ///
    /// - Parameters:
    ///   - attributes: Additional attributes of the <meta> tag.
    public init(attributes: [Attribute] = []) {
        let allAttributes = attributes
        super.init("meta", attributes: allAttributes)
    }
}
