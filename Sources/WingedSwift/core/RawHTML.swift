import Foundation

/// An HTML node that renders raw markup without a wrapper element.
///
/// Use `RawHTML` for imported HTML snippets — an SVG, an embed code — that you already have as a
/// string. It is never escaped. To group tags without an extra element, use ``Fragment`` instead:
/// it keeps the children as a tree, so pretty printing still works.
public class RawHTML: HTMLTag {
    private let raw: String

    /// Initializes a raw HTML node.
    ///
    /// - Parameter html: The HTML string to emit as-is (not escaped).
    public init(_ html: String) {
        self.raw = html
        super.init("", attributes: [], children: [], content: nil, escapeContent: false)
    }

    public override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
        if options.pretty {
            output += String(repeating: options.indent, count: indentLevel)
        }
        output += raw
    }
}
