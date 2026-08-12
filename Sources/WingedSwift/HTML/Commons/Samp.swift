import Foundation

/// Represents a <samp> HTML tag.
///
/// The <samp> tag marks sample output from a program.
public class Samp: HTMLTag {
    /// Initializes a new <samp> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <samp> tag.
    ///   - children: The children tags of the <samp> tag.
    ///   - content: The content of the <samp> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("samp", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <samp> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Samp {
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
