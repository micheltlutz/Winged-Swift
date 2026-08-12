import Foundation

/// How a tag tree is turned into markup.
///
/// Rendering options are a value passed into ``HTMLTag/render(_:)``, not global state, so two
/// tasks can render with different settings at the same time.
///
/// ## Example
/// ```swift
/// page.render(.pretty)
/// page.render(RenderOptions(pretty: true, indent: "    "))
/// ```
public struct RenderOptions: Sendable, Equatable {
    /// When true, children are placed on their own lines and indented.
    public var pretty: Bool

    /// The string used for one indentation level. Only used when `pretty` is true.
    public var indent: String

    /// When true, void elements render with an XHTML trailing slash (`<img … />`)
    /// instead of the HTML5 form (`<img …>`).
    public var xhtmlSelfClosing: Bool

    /// Creates a set of rendering options.
    ///
    /// - Parameters:
    ///   - pretty: Indent and break lines. Default is `false`.
    ///   - indent: One indentation level. Default is two spaces.
    ///   - xhtmlSelfClosing: Close void elements with ` />`. Default is `false`.
    public init(pretty: Bool = false, indent: String = "  ", xhtmlSelfClosing: Bool = false) {
        self.pretty = pretty
        self.indent = indent
        self.xhtmlSelfClosing = xhtmlSelfClosing
    }

    /// Minified output on a single line — the default, and what you should ship.
    public static let compact = RenderOptions()

    /// Indented, human-readable output.
    public static let pretty = RenderOptions(pretty: true)
}
