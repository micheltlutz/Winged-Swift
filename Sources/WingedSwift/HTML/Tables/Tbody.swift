import Foundation

/// Represents a <tbody> HTML tag.
///
/// The <tbody> tag groups the body rows of a `Table`.
public class Tbody: HTMLTag {
    /// Initializes a new <tbody> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <tbody> tag.
    ///   - children: The children tags of the <tbody> tag.
    ///   - content: The content of the <tbody> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("tbody", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <tbody> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Tbody {
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
