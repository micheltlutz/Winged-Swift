import Foundation

/// Represents an HTML tag.
open class HTMLTag {
    let name: String
    var attributes: [Attribute]
    var children: [HTMLTag]
    var content: String?

    /// Elements that have no closing tag.
    static let selfClosingTags: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img",
        "input", "link", "meta", "source", "track", "wbr"
    ]

    /// Elements whose text content is significant, so pretty printing must not add
    /// indentation or line breaks inside them.
    static let whitespaceSensitiveTags: Set<String> = ["pre", "code", "textarea"]

    /// Backing storage for the deprecated global switch. Reading it internally avoids
    /// emitting a deprecation warning inside the library itself.
    nonisolated(unsafe) static var legacyXHTMLSelfClosing = false

    /// When `true`, void elements render with an XHTML trailing slash (`<img … />`).
    ///
    /// - Warning: Process-wide mutable state. Use `RenderOptions(xhtmlSelfClosing: true)` and pass
    ///   it to ``render(_:)`` instead; this property is removed in 3.0.
    @available(*, deprecated, message: "Pass RenderOptions(xhtmlSelfClosing: true) to render(_:) instead.")
    public static var xhtmlSelfClosing: Bool {
        get { legacyXHTMLSelfClosing }
        set { legacyXHTMLSelfClosing = newValue }
    }

    /// The options used by the no-argument ``render()``, seeded from the deprecated global
    /// so 1.x code that flips `xhtmlSelfClosing` keeps producing the same markup.
    static var legacyOptions: RenderOptions {
        RenderOptions(xhtmlSelfClosing: legacyXHTMLSelfClosing)
    }

    /// Initializes a new HTML tag.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: The attributes of the HTML tag.
    ///   - children: The children tags of the HTML tag.
    ///   - content: The content of the HTML tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(_ name: String, attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil, escapeContent: Bool = true) {
        self.name = name
        self.attributes = attributes
        self.children = children
        if let content = content {
            self.content = escapeContent ? HTMLEscape.escape(content) : content
        } else {
            self.content = nil
        }
    }

    /// Adds an attribute to the HTML tag.
    ///
    /// - Parameter attribute: The attribute to add.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func addAttribute(_ attribute: Attribute) -> HTMLTag {
        attributes.append(attribute)
        return self
    }

    /// Adds a child tag to the HTML tag.
    ///
    /// - Parameter child: The child HTML tag.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func addChild(_ child: HTMLTag) -> HTMLTag {
        children.append(child)
        return self
    }

    /// Sets the content of the HTML tag.
    ///
    /// - Parameters:
    ///   - content: The content to be set.
    ///   - escape: If true, escapes HTML special characters. Default is true for security.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func setContent(_ content: String, escape: Bool = true) -> HTMLTag {
        self.content = escape ? HTMLEscape.escape(content) : content
        return self
    }

    // MARK: - Rendering

    /// Renders the tag and its subtree as a string.
    ///
    /// - Parameter options: How to format the output. Use ``RenderOptions/pretty`` for indented
    ///   markup and ``RenderOptions/compact`` for a single line.
    /// - Returns: The rendered HTML string.
    ///
    /// ## Example
    /// ```swift
    /// page.render(.pretty)
    /// ```
    public func render(_ options: RenderOptions) -> String {
        var output = ""
        output.reserveCapacity(1024)
        write(into: &output, options: options, indentLevel: 0)
        return output
    }

    /// Renders the tag and its subtree as a single line of markup.
    ///
    /// - Returns: The rendered HTML string.
    public func render() -> String {
        render(HTMLTag.legacyOptions)
    }

    /// Writes the tag and its subtree into an existing buffer.
    ///
    /// This is the primitive every other rendering method is built on: overriding it is how a
    /// subclass changes its markup (see ``RawHTML`` and ``Fragment``). Writing into a shared
    /// buffer avoids allocating an intermediate string per node.
    ///
    /// - Parameters:
    ///   - output: The buffer to append to.
    ///   - options: How to format the output.
    ///   - indentLevel: The current indentation depth, used when `options.pretty` is true.
    open func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
        if options.pretty {
            writePretty(into: &output, options: options, indentLevel: indentLevel)
        } else {
            writeCompact(into: &output, options: options)
        }
    }

    /// Appends the attribute list of an opening tag.
    private func writeAttributes(into output: inout String) {
        for attribute in attributes {
            if attribute.isBoolean {
                output += " \(attribute.key)"
            } else {
                output += " \(attribute.key)=\"\(attribute.value)\""
            }
        }
    }

    /// Appends the closing token of a void element (`>`, or ` />` in XHTML mode).
    private func writeSelfClosingSuffix(into output: inout String, options: RenderOptions) {
        output += options.xhtmlSelfClosing ? " />" : ">"
    }

    private func writeCompact(into output: inout String, options: RenderOptions) {
        output += "<\(name)"
        writeAttributes(into: &output)

        if HTMLTag.selfClosingTags.contains(name) {
            writeSelfClosingSuffix(into: &output, options: options)
            return
        }

        output += ">"

        if let content = content {
            output += content
        }

        for child in children {
            child.write(into: &output, options: options)
        }

        output += "</\(name)>"
    }

    private func writePretty(into output: inout String, options: RenderOptions, indentLevel: Int) {
        let indent = String(repeating: options.indent, count: indentLevel)

        // `<pre>`, `<code>` and `<textarea>` render every whitespace character they contain,
        // so indenting their children would change the text the browser displays.
        if HTMLTag.whitespaceSensitiveTags.contains(name) {
            output += indent
            writeCompact(into: &output, options: options)
            return
        }

        output += "\(indent)<\(name)"
        writeAttributes(into: &output)

        if HTMLTag.selfClosingTags.contains(name) {
            writeSelfClosingSuffix(into: &output, options: options)
            return
        }

        output += ">"

        if children.isEmpty {
            if let content = content {
                output += content
            }
            output += "</\(name)>"
            return
        }

        let nextIndent = String(repeating: options.indent, count: indentLevel + 1)
        if let content = content {
            output += "\n\(nextIndent)\(content)"
        }

        for child in children {
            // Rendering into a scratch buffer keeps empty nodes — an empty `Fragment` from a
            // false `if` — from leaving a blank line behind.
            var rendered = ""
            child.write(into: &rendered, options: options, indentLevel: indentLevel + 1)
            if !rendered.isEmpty {
                output += "\n"
                output += rendered
            }
        }

        output += "\n\(indent)</\(name)>"
    }

    // MARK: - Deprecated rendering API

    /// Renders the HTML tag as a string.
    ///
    /// - Parameters:
    ///   - pretty: If true, formats the HTML with indentation and line breaks.
    ///   - indentLevel: The current indentation level.
    /// - Returns: The rendered HTML string.
    @available(*, deprecated, message: "Use render(_:) with RenderOptions.")
    open func render(pretty: Bool, indentLevel: Int = 0) -> String {
        var options = HTMLTag.legacyOptions
        options.pretty = pretty
        var output = ""
        write(into: &output, options: options, indentLevel: indentLevel)
        return output
    }

    /// Renders the HTML tag as a compact string (no formatting).
    ///
    /// - Returns: The rendered HTML string without formatting.
    @available(*, deprecated, message: "Use render(.compact).")
    open func renderCompact() -> String {
        render(HTMLTag.legacyOptions)
    }

    /// Renders the HTML tag with pretty formatting (indentation and line breaks).
    ///
    /// - Parameter indentLevel: The current indentation level.
    /// - Returns: The formatted HTML string.
    @available(*, deprecated, message: "Use render(.pretty).")
    open func renderPretty(indentLevel: Int = 0) -> String {
        var options = HTMLTag.legacyOptions
        options.pretty = true
        var output = ""
        write(into: &output, options: options, indentLevel: indentLevel)
        return output
    }
}
