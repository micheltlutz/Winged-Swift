import Foundation

/// Represents an HTML tag.
open class HTMLTag {
    let name: String
    var attributes: [Attribute]
    var children: [HTMLTag]
    var content: String?

    private let selfClosingTags: Set<String> = ["img", "br", "hr", "input", "meta", "link", "embed"]

    /// When `true`, void elements render with an XHTML trailing slash (`<img … />`).
    /// Default is `false` for HTML5 (`<img …>`).
    public static var xhtmlSelfClosing: Bool = false

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

    /// Renders the HTML tag as a string.
    ///
    /// - Parameters:
    ///   - pretty: If true, formats the HTML with indentation and line breaks. Default is false.
    ///   - indentLevel: The current indentation level (used internally for recursion).
    /// - Returns: The rendered HTML string.
    open func render(pretty: Bool = false, indentLevel: Int = 0) -> String {
        if !pretty {
            return renderCompact()
        }

        return renderPretty(indentLevel: indentLevel)
    }

    /// Renders attribute list for opening tags.
    private func renderAttributes() -> String {
        var result = ""
        for attribute in attributes {
            if attribute.isBoolean {
                result += " \(attribute.key)"
            } else {
                result += " \(attribute.key)=\"\(attribute.value)\""
            }
        }
        return result
    }

    /// Closing token for void elements (`>` in HTML5, ` />` when `xhtmlSelfClosing` is true).
    private func selfClosingSuffix() -> String {
        HTMLTag.xhtmlSelfClosing ? " />" : ">"
    }

    /// Renders the HTML tag as a compact string (no formatting).
    ///
    /// - Returns: The rendered HTML string without formatting.
    open func renderCompact() -> String {
        var result = "<\(name)"
        result += renderAttributes()

        if selfClosingTags.contains(name) {
            result += selfClosingSuffix()
        } else {
            result += ">"

            if let content = content {
                result += content
            }

            for child in children {
                result += child.renderCompact()
            }

            result += "</\(name)>"
        }

        return result
    }

    /// Renders the HTML tag with pretty formatting (indentation and line breaks).
    ///
    /// - Parameter indentLevel: The current indentation level.
    /// - Returns: The formatted HTML string.
    open func renderPretty(indentLevel: Int = 0) -> String {
        let indent = String(repeating: "  ", count: indentLevel)
        let nextIndent = String(repeating: "  ", count: indentLevel + 1)
        var result = "\(indent)<\(name)"

        result += renderAttributes()

        if selfClosingTags.contains(name) {
            result += selfClosingSuffix()
            return result
        }

        result += ">"

        if let content = content, children.isEmpty {
            result += content
            result += "</\(name)>"
            return result
        }

        if !children.isEmpty {
            result += "\n"
            for child in children {
                result += child.renderPretty(indentLevel: indentLevel + 1)
                result += "\n"
            }
            result += "\(indent)</\(name)>"
        } else if let content = content {
            result += "\n\(nextIndent)\(content)\n"
            result += "\(indent)</\(name)>"
        } else {
            result += "</\(name)>"
        }

        return result
    }
}
