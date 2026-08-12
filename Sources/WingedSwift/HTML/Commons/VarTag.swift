import Foundation

/// Represents a <var> HTML tag.
///
/// The <var> tag marks a variable name. Named `VarTag` because `var` is a Swift keyword.
public class VarTag: HTMLTag {
    /// Initializes a new <var> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <var> tag.
    ///   - children: The children tags of the <var> tag.
    ///   - content: The content of the <var> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("var", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <var> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// VarTag {
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
