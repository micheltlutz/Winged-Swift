import Foundation

/// Represents a <time> HTML tag.
///
/// The <time> tag defines a specific time (or datetime).
public class Time: HTMLTag {
    /// Initializes a new <time> tag.
    ///
    /// - Parameters:
    ///   - datetime: The machine-readable datetime value.
    ///   - attributes: Additional attributes of the <time> tag.
    ///   - children: Nested tags inside the <time> tag.
    ///   - content: The human-readable content of the <time> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(datetime: String? = nil, attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        var allAttributes = attributes
        if let datetime = datetime {
            allAttributes.append(Attribute(key: "datetime", value: datetime, escape: false))
        }
        super.init("time", attributes: allAttributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <time> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Time {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        datetime: String? = nil,
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            datetime: datetime,
            attributes: attributes,
            children: children(),
            content: content,
            escapeContent: escapeContent
        )
    }
}
