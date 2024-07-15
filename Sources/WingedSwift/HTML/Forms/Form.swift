import Foundation

/// Represents a <form> HTML tag.
public class Form: HTMLTag {
    /// Initializes a new <form> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <form> tag.
    ///   - children: The children tags of the <form> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("form", attributes: attributes, children: children)
    }
}
