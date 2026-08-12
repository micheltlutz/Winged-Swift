import Foundation

/// Represents a <label> HTML tag.
public class Label: HTMLTag {
    /// Initializes a new <label> tag.
    ///
    /// - Parameters:
    ///   - id: The ID of the element this label is for (`for` attribute). Optional (e.g. CMP labels).
    ///   - content: The content of the label element.
    ///   - attributes: Additional attributes of the <label> tag.
    ///   - children: Nested tags inside the label.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(
        for id: String? = nil,
        content: String? = nil,
        attributes: [Attribute] = [],
        children: [HTMLTag] = [],
        escapeContent: Bool = true
    ) {
        var allAttributes = attributes
        if let id = id {
            allAttributes.append(Attribute(key: "for", value: id))
        }
        super.init("label", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <label> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Label {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        for id: String? = nil,
        content: String? = nil,
        attributes: [Attribute] = [],
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            for: id,
            content: content,
            attributes: attributes,
            children: children(),
            escapeContent: escapeContent
        )
    }
}
