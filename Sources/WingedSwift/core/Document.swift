import Foundation

/// A complete HTML document: the doctype, the `<html>` root with its language, and the
/// `<head>` / `<body>` pair.
///
/// `html { }` builds the `<html>` element only — the doctype used to live inside
/// ``StaticSiteGenerator`` and the language had to be bolted on with `setAttribute`. A `Document`
/// owns both, so a correct page is the default rather than something you remember to assemble.
///
/// It is a value type holding a tag tree, so it is deliberately **not** `Sendable`: build it and
/// render it inside one task, then pass the resulting `String` across isolation boundaries.
///
/// ## Example
/// ```swift
/// let page = Document(lang: "pt-BR") {
///     Meta(charset: "UTF-8")
///     Title(content: "Início")
/// } body: {
///     H1(content: "Olá")
/// }
///
/// print(page.render())
/// // <!DOCTYPE html>
/// // <html lang="pt-BR">
/// //   <head>
/// //     …
/// ```
public struct Document {
    /// The `lang` attribute of the `<html>` element. Omitted when `nil`.
    public var lang: String?

    /// The document `<head>`.
    public var head: Head

    /// The document `<body>`.
    public var body: Body

    /// Creates a document from an existing head and body.
    ///
    /// - Parameters:
    ///   - lang: The language of the document, e.g. `"pt-BR"`. Omitted when `nil`.
    ///   - head: The document head.
    ///   - body: The document body.
    public init(lang: String? = nil, head: Head, body: Body) {
        self.lang = lang
        self.head = head
        self.body = body
    }

    /// Creates a document from two result builders.
    ///
    /// - Parameters:
    ///   - lang: The language of the document, e.g. `"pt-BR"`. Omitted when `nil`.
    ///   - head: A builder closure producing the contents of `<head>`.
    ///   - body: A builder closure producing the contents of `<body>`.
    public init(
        lang: String? = nil,
        @HTMLFragmentBuilder head: () -> [HTMLTag],
        @HTMLFragmentBuilder body: () -> [HTMLTag]
    ) {
        self.init(lang: lang,
                  head: Head(children: head()),
                  body: Body(children: body()))
    }

    /// The `<html>` element of this document, without the doctype.
    ///
    /// Useful when something else owns the doctype, or to keep chaining tag helpers.
    public func root() -> HTMLTag {
        let root = HTMLTag("html", children: [head, body])
        if let lang = lang {
            root.attributes.append(Attribute(key: "lang", value: lang))
        }
        return root
    }

    /// Renders the document, doctype included.
    ///
    /// - Parameter options: How to format the output. Defaults to ``RenderOptions/pretty``,
    ///   since a document is normally a file a human may open.
    /// - Returns: The rendered HTML, starting with `<!DOCTYPE html>`.
    public func render(_ options: RenderOptions = .pretty) -> String {
        var output = "<!DOCTYPE html>\n"
        output.reserveCapacity(2048)
        root().write(into: &output, options: options, indentLevel: 0)
        return output
    }

    /// Writes the document to a file without building the whole page in memory.
    ///
    /// The output is byte-for-byte what ``render(_:)`` returns. Each child of `<body>` is rendered
    /// and flushed in turn, so memory stays bounded by the largest section rather than the page.
    /// The file is replaced atomically.
    ///
    /// - Parameters:
    ///   - path: The file to write; its directory must exist.
    ///   - options: How to format the markup. Defaults to ``RenderOptions/pretty``.
    /// - Throws: ``WingedError/writeFailed(path:underlying:)`` if the file cannot be written.
    public func write(toFile path: String, options: RenderOptions = .pretty) throws(WingedError) {
        let temporary = path + ".winged-tmp"
        // `OutputStream(toFileAtPath:)` only returns nil for an empty path; failures surface on write.
        guard let output = OutputStream(toFileAtPath: temporary, append: false) else { throw .writeFailed(path: path, underlying: CocoaError(.fileWriteUnknown)) }
        output.open()
        var failed = false
        var buffer = ""
        func emit(_ text: String, flush: Bool = false) {
            buffer += text
            guard flush || buffer.utf8.count >= 64 * 1024, !failed else { return }
            let bytes = Array(buffer.utf8)
            buffer.removeAll(keepingCapacity: true)
            var offset = 0
            while offset < bytes.count {
                let written = bytes[offset...].withUnsafeBufferPointer { output.write($0.baseAddress!, maxLength: $0.count) }
                guard written > 0 else {
                    failed = true
                    return
                }
                offset += written
            }
        }

        writePieces(into: { emit($0, flush: $1) }, options: options)
        emit("", flush: true)
        output.close()
        do {
            guard !failed else { throw output.streamError ?? CocoaError(.fileWriteUnknown) }
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }
            try FileManager.default.moveItem(atPath: temporary, toPath: path)
        } catch {
            try? FileManager.default.removeItem(atPath: temporary)
            throw .writeFailed(path: path, underlying: error)
        }
    }

    /// Produces the markup of ``render(_:)`` in pieces: `<body>`'s children one at a time.
    func writePieces(into emit: (String, Bool) -> Void, options: RenderOptions) {
        let root = root()
        // A body with content or no children renders like any other tag; stream only the common
        // case of a body made of sections.
        guard body.content == nil, !body.children.isEmpty else {
            emit(render(options), false)
            return
        }
        emit("<!DOCTYPE html>\n" + root.openingTag(), false)
        if options.pretty {
            let bodyIndent = options.indent
            var head = "\n"
            head.reserveCapacity(1024)
            self.head.write(into: &head, options: options, indentLevel: 1)
            emit(head + "\n" + bodyIndent + body.openingTag(), false)
            for child in body.children {
                var rendered = ""
                child.write(into: &rendered, options: options, indentLevel: 2)
                if !rendered.isEmpty {
                    emit("\n" + rendered, false)
                }
            }
            emit("\n" + bodyIndent + "</body>\n</html>", false)
        } else {
            emit(head.render(options) + body.openingTag(), false)
            for child in body.children {
                emit(child.render(options), false)
            }
            emit("</body></html>", false)
        }
    }
}
