import Foundation

/// Represents a <td> HTML tag.
public class Td: HTMLTag {
    /// Initializes a new <td> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <td> tag.
    ///   - children: The children tags of the <td> tag.
    ///   - content: The content of the <td> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("td", attributes: attributes, children: children, content: content)
    }
}
