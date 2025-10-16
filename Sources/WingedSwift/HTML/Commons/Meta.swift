import Foundation

/// Represents a <meta> HTML tag.
public class Meta: HTMLTag {
    /// Initializes a new <meta> tag with name and content.
    ///
    /// - Parameters:
    ///   - name: The name of the metadata.
    ///   - content: The value of the metadata.
    ///   - attributes: Additional attributes of the <meta> tag.
    public init(name: String, content: String, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "name", value: name, escape: false))
        allAttributes.append(Attribute(key: "content", value: content))
        super.init("meta", attributes: allAttributes)
    }
    
    /// Initializes a new <meta> tag with property and content (for Open Graph).
    ///
    /// - Parameters:
    ///   - property: The property attribute (e.g., "og:title").
    ///   - content: The value of the property.
    ///   - attributes: Additional attributes of the <meta> tag.
    public init(property: String, content: String, attributes: [Attribute] = []) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "property", value: property, escape: false))
        allAttributes.append(Attribute(key: "content", value: content))
        super.init("meta", attributes: allAttributes)
    }
    
    /// Initializes a new <meta> tag with charset.
    ///
    /// - Parameter charset: The character encoding (e.g., "UTF-8").
    public init(charset: String) {
        super.init("meta", attributes: [Attribute(key: "charset", value: charset, escape: false)])
    }
    
    /// Initializes a new <meta> tag with http-equiv.
    ///
    /// - Parameters:
    ///   - httpEquiv: The http-equiv attribute value.
    ///   - content: The content value.
    public init(httpEquiv: String, content: String) {
        let attributes = [
            Attribute(key: "http-equiv", value: httpEquiv, escape: false),
            Attribute(key: "content", value: content)
        ]
        super.init("meta", attributes: attributes)
    }
    
    /// Initializes a new <meta> tag with custom attributes.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <meta> tag.
    public init(attributes: [Attribute] = []) {
        super.init("meta", attributes: attributes)
    }
}
