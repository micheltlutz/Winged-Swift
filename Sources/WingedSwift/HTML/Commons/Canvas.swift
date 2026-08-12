import Foundation

/// Represents a <canvas> HTML tag.
///
/// The <canvas> tag defines a drawing surface scripted with JavaScript.
public class Canvas: HTMLTag {
    /// Initializes a new <canvas> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <canvas> tag.
    ///   - children: The children tags of the <canvas> tag.
    ///   - content: The content of the <canvas> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("canvas", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <canvas> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Canvas {
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
