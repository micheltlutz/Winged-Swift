import Foundation

/// Represents a <summary> HTML tag.
///
/// The <summary> tag is the always-visible label of a `Details` disclosure widget.
public class Summary: HTMLTag {
    /// Initializes a new <summary> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <summary> tag.
    ///   - children: The children tags of the <summary> tag.
    ///   - content: The content of the <summary> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        super.init("summary", attributes: attributes, children: children, content: content, escapeContent: escapeContent)
    }

    /// Initializes a new <summary> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Summary {
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
