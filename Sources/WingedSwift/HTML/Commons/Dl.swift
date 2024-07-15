import Foundation

/// Represents a <dl> HTML tag.
public class Dl: HTMLTag {
    /// Initializes a new <dl> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <dl> tag.
    ///   - children: The children tags of the <dl> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("dl", attributes: attributes, children: children)
    }
}
