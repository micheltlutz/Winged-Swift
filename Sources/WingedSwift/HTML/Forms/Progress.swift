import Foundation

/// Represents a <progress> HTML tag.
///
/// The content is the fallback text shown by browsers without progress support.
public class Progress: HTMLTag {
    /// Initializes a new <progress> tag.
    ///
    /// - Parameters:
    ///   - value: The current progress value (optional; omit for an indeterminate bar).
    ///   - max: The value that represents completion. Defaults to `1.0`.
    ///   - attributes: Additional attributes of the <progress> tag.
    ///   - content: The fallback content of the <progress> tag.
    public init(value: Double? = nil, max: Double = 1.0, attributes: [Attribute] = [], content: String? = nil) {
        var allAttributes = attributes
        if let value = value {
            allAttributes.append(Attribute(key: "value", value: String(value), escape: false))
        }
        allAttributes.append(Attribute(key: "max", value: String(max), escape: false))
        super.init("progress", attributes: allAttributes, content: content)
    }
}
