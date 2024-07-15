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
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
