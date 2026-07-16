import Foundation

/// Represents a <button> HTML tag.
public class Button: HTMLTag {
    /// Initializes a new <button> tag.
    ///
    /// - Parameters:
    ///   - type: The button type (`button`, `submit`, or `reset`). Defaults to `"button"`.
    ///     Pass `nil` to omit the `type` attribute. If `attributes` already contains `type`, it is kept.
    ///   - attributes: The attributes of the <button> tag.
    ///   - children: The children tags of the <button> tag.
    ///   - content: The content of the <button> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(
        type: String? = "button",
        attributes: [Attribute] = [],
        children: [HTMLTag] = [],
        content: String? = nil,
        escapeContent: Bool = true
    ) {
        var allAttributes = attributes
        if !allAttributes.contains(where: { $0.key == "type" }), let type = type {
            allAttributes.append(Attribute(key: "type", value: type))
        }
        super.init("button", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }
}
