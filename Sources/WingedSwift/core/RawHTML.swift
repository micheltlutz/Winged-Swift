import Foundation

/// An HTML node that renders raw markup without a wrapper element.
///
/// Use `RawHTML` for imported HTML snippets or for aggregating a fragment of tags
/// without introducing an extra container (unlike wrapping content in a `Div`).
public class RawHTML: HTMLTag {
    private let raw: String

    /// Initializes a raw HTML node.
    ///
    /// - Parameter html: The HTML string to emit as-is (not escaped).
    public init(_ html: String) {
        self.raw = html
        super.init("", attributes: [], children: [], content: nil, escapeContent: false)
    }

    public override func render(pretty: Bool = false, indentLevel: Int = 0) -> String {
        if pretty {
            let indent = String(repeating: "  ", count: indentLevel)
            return "\(indent)\(raw)"
        }
        return raw
    }

    public override func renderCompact() -> String {
        raw
    }

    public override func renderPretty(indentLevel: Int = 0) -> String {
        let indent = String(repeating: "  ", count: indentLevel)
        return "\(indent)\(raw)"
    }
}
