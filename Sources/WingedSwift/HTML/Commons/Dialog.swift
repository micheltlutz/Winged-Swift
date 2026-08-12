import Foundation

/// Represents a <dialog> HTML tag.
///
/// The <dialog> tag defines a modal or non-modal dialog box.
public class Dialog: HTMLTag {
    /// Initializes a new <dialog> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <dialog> tag.
    ///   - children: The children tags of the <dialog> tag.
    ///   - content: The content of the <dialog> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("dialog", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <dialog> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Dialog {
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
