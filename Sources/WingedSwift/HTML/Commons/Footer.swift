import Foundation

/// Represents a <footer> HTML tag.
public class Footer: HTMLTag {
    /// Initializes a new <footer> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <footer> tag.
    ///   - children: The children tags of the <footer> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("footer", attributes: attributes, children: children)
    }
}
