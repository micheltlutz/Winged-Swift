import Foundation

/// Represents a <section> HTML tag.
public class Section: HTMLTag {
    /// Initializes a new <section> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <section> tag.
    ///   - children: The children tags of the <section> tag.
    ///   - content: The content of the <section> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("section", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <section> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Section {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
