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
}
