import Foundation

/// Represents a <abbr> HTML tag.
///
/// The <abbr> tag marks an abbreviation or acronym; pair it with a `title` attribute for the expansion.
public class Abbr: HTMLTag {
    /// Initializes a new <abbr> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <abbr> tag.
    ///   - children: The children tags of the <abbr> tag.
    ///   - content: The content of the <abbr> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("abbr", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <abbr> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Abbr {
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
