import Foundation

/// Represents a <q> HTML tag.
///
/// The <q> tag marks a short inline quotation; browsers add the quotation marks.
public class Q: HTMLTag {
    /// Initializes a new <q> tag.
    ///
    /// - Parameters:
    ///   - cite: The URL of the source of the quotation (optional).
    ///   - attributes: Additional attributes of the <q> tag.
    ///   - children: The children tags of the <q> tag.
    ///   - content: The content of the <q> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(
        cite: String? = nil,
        attributes: [Attribute] = [],
        children: [HTMLTag] = [],
        content: String? = nil,
        escapeContent: Bool = true
    ) {
        var allAttributes = attributes
        if let cite = cite {
            allAttributes.append(Attribute(key: "cite", value: cite))
        }
        super.init("q", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <q> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Q {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        cite: String? = nil,
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            cite: cite,
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
