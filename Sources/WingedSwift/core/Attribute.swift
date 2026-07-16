import Foundation

/// Represents an HTML attribute with a key and a value.
public class Attribute {
    let key: String
    let value: String
    /// When true, the attribute renders as ` key` with no `="value"` (e.g. `hidden`, `checked`).
    let isBoolean: Bool

    /// Initializes a new HTML attribute.
    ///
    /// - Parameters:
    ///   - key: The attribute name.
    ///   - value: The attribute value.
    ///   - escape: If true, escapes HTML special characters in the value. Default is true for security.
    public init(key: String, value: String, escape: Bool = true) {
        self.key = key
        self.value = escape ? HTMLEscape.escapeAttribute(value) : value
        self.isBoolean = false
    }

    private init(booleanKey: String) {
        self.key = booleanKey
        self.value = ""
        self.isBoolean = true
    }

    /// Creates a boolean HTML attribute that renders only the key (e.g. `disabled`, `required`).
    ///
    /// - Parameter key: The attribute name.
    /// - Returns: A boolean attribute instance.
    public static func boolean(_ key: String) -> Attribute {
        Attribute(booleanKey: key)
    }
}
