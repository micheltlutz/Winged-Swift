import Foundation

/// Represents a <details> HTML tag.
///
/// The <details> tag is a disclosure widget. Its first child should be a `Summary`,
/// which stays visible while the rest is toggled.
///
/// ## Example
/// ```swift
/// Details(open: true, children: [
///     Summary(content: "How do I install it?"),
///     P(content: "Add the package to your Package.swift.")
/// ])
/// ```
public class Details: HTMLTag {
    /// Initializes a new <details> tag.
    ///
    /// - Parameters:
    ///   - open: If true, renders the boolean `open` attribute so the widget starts expanded.
    ///   - attributes: Additional attributes of the <details> tag.
    ///   - children: The children tags of the <details> tag.
    ///   - content: The content of the <details> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(
        open: Bool = false,
        attributes: [Attribute] = [],
        children: [HTMLTag] = [],
        content: String? = nil,
        escapeContent: Bool = true
    ) {
        var allAttributes = attributes
        if open {
            allAttributes.append(.boolean("open"))
        }
        super.init("details", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <details> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Details {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        open: Bool = false,
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            open: open,
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
