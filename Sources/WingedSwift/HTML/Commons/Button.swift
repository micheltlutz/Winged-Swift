import Foundation

/// Represents a <button> HTML tag.
public class Button: HTMLTag {
    /// Initializes a new <button> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <button> tag.
    ///   - children: The children tags of the <button> tag.
    ///   - content: The content of the <button> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        super.init("button", attributes: attributes, children: children, content: content)
        self.attributes.append(Attribute(key: "type", value: "button"))
    }
}
