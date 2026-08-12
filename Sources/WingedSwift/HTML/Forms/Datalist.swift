import Foundation

/// Represents a <datalist> HTML tag.
///
/// The <datalist> tag holds the `Option` suggestions of an `Input` referencing it by id.
public class Datalist: HTMLTag {
    /// Initializes a new <datalist> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <datalist> tag.
    ///   - children: The children tags of the <datalist> tag.
    ///   - content: The content of the <datalist> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("datalist", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <datalist> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Datalist {
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
