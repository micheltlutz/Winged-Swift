import Foundation

/// Represents a <thead> HTML tag.
///
/// The <thead> tag groups the header rows of a `Table`.
public class Thead: HTMLTag {
    /// Initializes a new <thead> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <thead> tag.
    ///   - children: The children tags of the <thead> tag.
    ///   - content: The content of the <thead> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("thead", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <thead> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Thead {
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
