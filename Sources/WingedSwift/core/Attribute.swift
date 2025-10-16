import Foundation

/// Represents an HTML attribute with a key and a value.
public class Attribute {
    let key: String
    let value: String
    
    /// Initializes a new HTML attribute.
    ///
    /// - Parameters:
    ///   - key: The attribute name.
    ///   - value: The attribute value.
    ///   - escape: If true, escapes HTML special characters in the value. Default is true for security.
    public init(key: String, value: String, escape: Bool = true) {
        self.key = key
        self.value = escape ? HTMLEscape.escapeAttribute(value) : value
    }
}
