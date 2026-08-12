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

    /// Initializes a new <button> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Button {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        type: String? = "button",
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            type: type,
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
