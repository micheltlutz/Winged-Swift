import Foundation

/// A run of text with no element around it.
///
/// Builders create one for every bare string, so text can sit next to inline elements without a
/// wrapping `<span>`. The text is escaped once, when the node is created.
///
/// ## Example
/// ```swift
/// P {
///     "Made with "
///     Strong(content: "WingedSwift")
/// }
/// // <p>Made with <strong>WingedSwift</strong></p>
/// ```
public final class TextNode: HTMLTag {
    private let text: String

    /// Creates a text node.
    ///
    /// - Parameters:
    ///   - text: The text to render.
    ///   - escape: If true (the default), escapes HTML special characters.
    public init(_ text: String, escape: Bool = true) {
        self.text = escape ? HTMLEscape.escape(text) : text
        super.init("", attributes: [], children: [], content: nil, escapeContent: false)
    }

    /// Two adjacent nodes as one, without escaping twice.
    static func joined(_ first: TextNode, _ second: TextNode) -> TextNode {
        TextNode(first.text + second.text, escape: false)
    }

    public override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
        if options.pretty {
            output += String(repeating: options.indent, count: indentLevel)
        }
        output += text
    }

    public override func copy() -> HTMLTag {
        TextNode(text, escape: false)
    }
}
