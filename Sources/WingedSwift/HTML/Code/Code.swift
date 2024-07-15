import Foundation

/// Represents a <code> HTML tag.
public class Code: HTMLTag {
    /// Initializes a new <code> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <code> tag.
    ///   - content: The content of the <code> tag.
    public init(attributes: [Attribute] = [], content: String? = nil) {
        super.init("code", attributes: attributes, content: content)
    }
}
