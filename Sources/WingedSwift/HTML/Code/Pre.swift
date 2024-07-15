import Foundation

/// Represents a <pre> HTML tag.
public class Pre: HTMLTag {
    /// Initializes a new <pre> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <pre> tag.
    ///   - content: The content of the <pre> tag.
    public init(attributes: [Attribute] = [], content: String? = nil) {
        super.init("pre", attributes: attributes, content: content)
    }
}
