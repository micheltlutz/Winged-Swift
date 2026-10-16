import Foundation

/// Options for ``Markdown``.
public struct MarkdownOptions: Sendable, Equatable {
    /// Pass HTML blocks and inline tags through unescaped. Off by default: Markdown text is
    /// escaped like any other content unless you opt in for sources you control.
    public var rawHTML: Bool
    /// Give every heading an `id` slug (`## Getting started` → `id="getting-started"`), so it can
    /// be linked to.
    public var headingIDs: Bool

    /// Creates options.
    ///
    /// - Parameters:
    ///   - rawHTML: Pass raw HTML through. Defaults to `false`.
    ///   - headingIDs: Add `id`s to headings. Defaults to `true`.
    public init(rawHTML: Bool = false, headingIDs: Bool = true) {
        self.rawHTML = rawHTML
        self.headingIDs = headingIDs
    }
}

/// A dependency-free Markdown renderer for a documented subset of CommonMark and GitHub
/// Flavored Markdown.
///
/// Supported: ATX headings, paragraphs and hard line breaks, `*em*` / `_em_`, `**strong**`,
/// `~~strikethrough~~`, inline code, links, images, `<https://…>` autolinks, backslash escapes,
/// ordered and unordered lists (nested by indentation), fenced code blocks with a language,
/// blockquotes, thematic breaks, pipe tables with alignment, and — with
/// ``MarkdownOptions/rawHTML`` — raw HTML. Not supported: setext headings, indented code blocks,
/// reference-style links, footnotes.
///
/// The result is a tag tree, so escaping and ``RenderOptions`` apply as usual. Blocks whose
/// content is inline (paragraphs, headings, list items, table cells) always render on one line,
/// even with ``RenderOptions/pretty``, because indentation inside them would be visible text.
///
/// ## Example
/// ```swift
/// let tags = Markdown.parse("# Hello\n\nSome *emphasis* and `code`.")
/// Div(children: tags).render()
/// // <div><h1 id="hello">Hello</h1><p>Some <em>emphasis</em> and <code>code</code>.</p></div>
/// ```
public enum Markdown {
    /// Renders Markdown into tags.
    ///
    /// - Parameters:
    ///   - source: The Markdown text.
    ///   - options: What to allow and generate.
    /// - Returns: The block-level tags, in order.
    public static func parse(_ source: String, options: MarkdownOptions = MarkdownOptions()) -> [HTMLTag] {
        var parser = BlockParser(options: options)
        let lines = source.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        return parser.blocks(lines)
    }

    /// The plain text of Markdown, without markup — for word counts and summaries.
    ///
    /// - Parameter source: The Markdown text.
    /// - Returns: The text, with formatting characters, link targets and HTML tags removed.
    public static func plainText(_ source: String) -> String {
        let html = Div(children: parse(source)).render(.compact)
        var text = ""
        var inTag = false
        for character in html {
            switch character {
            case "<": inTag = true; text.append(" ")
            case ">": inTag = false
            default: if !inTag { text.append(character) }
            }
        }
        return HTMLEscape.unescape(text)
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}

extension HTMLTag {
    /// Keeps this element on one line in pretty output.
    ///
    /// Pretty printing puts every child on its own line, which adds visible whitespace between
    /// text and inline elements — `name!` can render as `name !`. Mark elements whose children are
    /// inline (a paragraph with links, a list item with a date) to render them compactly, at the
    /// right indentation. Compact output is unchanged.
    ///
    /// - Returns: The element, wrapped. Call it last: the result is a plain `HTMLTag`.
    ///
    /// ## Example
    /// ```swift
    /// P {
    ///     "Posted on "
    ///     Time(datetime: "2026-10-15", content: "15 Oct")
    ///     "."
    /// }
    /// .addClass("meta")
    /// .inline()
    /// // <p class="meta">Posted on <time datetime="2026-10-15">15 Oct</time>.</p>
    /// ```
    public func inline() -> HTMLTag {
        InlineFlow(self)
    }
}

/// Renders its child compactly even inside pretty output, at the current indentation.
final class InlineFlow: HTMLTag {
    init(_ tag: HTMLTag) {
        super.init("", attributes: [], children: [tag], content: nil, escapeContent: false)
    }

    override func copy() -> HTMLTag {
        InlineFlow(Fragment(children: children.map { $0.copy() }))
    }

    override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
        var compact = options
        compact.pretty = false
        if options.pretty {
            output += String(repeating: options.indent, count: indentLevel)
        }
        for child in children {
            child.write(into: &output, options: compact)
        }
    }
}

// MARK: - Blocks

private struct BlockParser {
    let options: MarkdownOptions
    var usedIDs: [String: Int] = [:]

    init(options: MarkdownOptions) {
        self.options = options
    }

    mutating func blocks(_ lines: [String]) -> [HTMLTag] {
        var tags: [HTMLTag] = []
        var index = 0
        var paragraph: [String] = []

        func flush(_ parser: inout BlockParser) {
            if !paragraph.isEmpty {
                tags.append(InlineFlow(P(children: parser.inline(paragraph))))
                paragraph.removeAll()
            }
        }

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                flush(&self)
                index += 1
            } else if let fence = Self.fence(line) {
                flush(&self)
                tags.append(Self.fencedCode(lines, from: &index, fence: fence))
            } else if let heading = Self.heading(trimmed) {
                flush(&self)
                tags.append(InlineFlow(headingTag(level: heading.level, text: heading.text)))
                index += 1
            } else if Self.isThematicBreak(trimmed) {
                flush(&self)
                tags.append(Hr())
                index += 1
            } else if trimmed.hasPrefix(">") {
                flush(&self)
                tags.append(Blockquote(children: blocks(Self.quoted(lines, from: &index))))
            } else if Self.listMarker(line) != nil {
                flush(&self)
                tags.append(list(lines, from: &index))
            } else if paragraph.isEmpty, index + 1 < lines.count, trimmed.contains("|"),
                      let alignments = Self.tableSeparator(lines[index + 1]) {
                tags.append(table(lines, from: &index, alignments: alignments))
            } else if options.rawHTML, paragraph.isEmpty, Self.startsHTMLBlock(trimmed) {
                var html: [String] = []
                while index < lines.count, !lines[index].trimmingCharacters(in: .whitespaces).isEmpty {
                    html.append(lines[index])
                    index += 1
                }
                tags.append(RawHTML(html.joined(separator: "\n")))
            } else {
                paragraph.append(line)
                index += 1
            }
        }
        flush(&self)
        return tags
    }

    /// A fenced code block, from its opening fence to the closing one (or the end).
    static func fencedCode(_ lines: [String], from index: inout Int, fence: (marker: String, language: String)) -> HTMLTag {
        var code: [String] = []
        index += 1
        while index < lines.count, !closes(lines[index], fence: fence.marker) {
            code.append(lines[index])
            index += 1
        }
        index += 1
        let language = fence.language.isEmpty ? [] : [Attribute(key: "class", value: "language-\(fence.language)")]
        return Pre(children: [Code(attributes: language, content: code.joined(separator: "\n"))])
    }

    /// The lines of a blockquote, with their `>` removed.
    static func quoted(_ lines: [String], from index: inout Int) -> [String] {
        var quoted: [String] = []
        while index < lines.count {
            let current = lines[index].trimmingCharacters(in: .whitespaces)
            guard current.hasPrefix(">") else { break }
            var rest = current.dropFirst()
            if rest.hasPrefix(" ") { rest = rest.dropFirst() }
            quoted.append(String(rest))
            index += 1
        }
        return quoted
    }

    // Headings

    static func heading(_ line: String) -> (level: Int, text: String)? {
        let hashes = line.prefix { $0 == "#" }.count
        guard (1...6).contains(hashes) else { return nil }
        let rest = line.dropFirst(hashes)
        guard rest.isEmpty || rest.first == " " else { return nil }
        var text = rest.trimmingCharacters(in: .whitespaces)
        while text.hasSuffix("#") { text.removeLast() }
        return (hashes, text.trimmingCharacters(in: .whitespaces))
    }

    mutating func headingTag(level: Int, text: String) -> HTMLTag {
        let children = inline([text])
        var attributes: [Attribute] = []
        if options.headingIDs {
            let base = Self.slug(Markdown.plainText(text))
            let previousUses = usedIDs[base, default: 0]
            usedIDs[base] = previousUses + 1
            attributes.append(Attribute(key: "id", value: previousUses == 0 ? base : "\(base)-\(previousUses)"))
        }
        return HTMLTag("h\(level)", attributes: attributes, children: children)
    }

    static func slug(_ text: String) -> String {
        var slug = ""
        for character in text.lowercased() {
            if character.isLetter || character.isNumber {
                slug.append(character)
            } else if (character == " " || character == "-") && !slug.hasSuffix("-") {
                slug.append("-")
            }
        }
        let trimmed = slug.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return trimmed.isEmpty ? "section" : trimmed
    }

    // Thematic breaks and fences

    static func isThematicBreak(_ line: String) -> Bool {
        let compact = line.filter { $0 != " " }
        guard let first = compact.first, "-*_".contains(first), compact.count >= 3 else { return false }
        return compact.allSatisfy { $0 == first }
    }

    static func fence(_ line: String) -> (marker: String, language: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        for marker in ["```", "~~~"] where trimmed.hasPrefix(marker) {
            let run = trimmed.prefix { $0 == marker.first }
            let language = trimmed.dropFirst(run.count).trimmingCharacters(in: .whitespaces)
                .split(separator: " ").first.map(String.init) ?? ""
            return (String(run), language)
        }
        return nil
    }

    static func closes(_ line: String, fence: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return trimmed.hasPrefix(fence) && trimmed.allSatisfy { $0 == fence.first }
    }

    // Lists

    struct Marker {
        let indent: Int
        let ordered: Bool
        /// `-`, `*`, `+`, or the ordered delimiter `.` / `)`; a different one starts a new list.
        let symbol: Character
        let start: Int
        /// Columns up to the item text.
        let width: Int
    }

    static func listMarker(_ line: String) -> Marker? {
        let indent = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(indent)
        if let first = rest.first, "-*+".contains(first), rest.dropFirst().first == " " {
            return Marker(indent: indent, ordered: false, symbol: first, start: 1, width: indent + 2)
        }
        let digits = rest.prefix { $0.isNumber }
        guard !digits.isEmpty, digits.count <= 9 else { return nil }
        let after = rest.dropFirst(digits.count)
        guard let delimiter = after.first, delimiter == "." || delimiter == ")", after.dropFirst().first == " " else {
            return nil
        }
        return Marker(indent: indent, ordered: true, symbol: delimiter, start: Int(digits) ?? 1,
                      width: indent + digits.count + 2)
    }

    mutating func list(_ lines: [String], from index: inout Int) -> HTMLTag {
        guard let first = Self.listMarker(lines[index]) else { return Fragment() }
        var items: [[String]] = []
        while index < lines.count {
            let line = lines[index]
            if let marker = Self.listMarker(line), marker.indent == first.indent, marker.symbol == first.symbol {
                items.append([String(line.dropFirst(marker.width))])
                index += 1
                continue
            }
            let indent = line.prefix { $0 == " " }.count
            let isBlank = line.trimmingCharacters(in: .whitespaces).isEmpty
            if isBlank {
                // A blank line continues the list only if the next line is still part of it.
                let next = index + 1 < lines.count ? lines[index + 1] : ""
                let nextIndent = next.prefix { $0 == " " }.count
                let continues = (Self.listMarker(next).map { $0.indent == first.indent && $0.symbol == first.symbol } ?? false)
                    || (!next.trimmingCharacters(in: .whitespaces).isEmpty && nextIndent >= first.width)
                guard continues else { break }
                items[items.count - 1].append("")
                index += 1
            } else if indent >= first.width || (indent > first.indent && Self.listMarker(line) != nil) {
                items[items.count - 1].append(String(line.dropFirst(min(indent, first.width))))
                index += 1
            } else if Self.listMarker(line) == nil, Self.fence(line) == nil, Self.heading(line.trimmingCharacters(in: .whitespaces)) == nil,
                      !line.trimmingCharacters(in: .whitespaces).hasPrefix(">"), items.last?.last?.isEmpty == false {
                // Lazy continuation of the item's paragraph.
                items[items.count - 1].append(line.trimmingCharacters(in: .whitespaces))
                index += 1
            } else {
                break
            }
        }

        // A list is loose when a blank line separates two items or two blocks of one item; then
        // every item keeps its paragraphs. Otherwise item text sits directly in the <li>.
        let loose = items.dropLast().contains { $0.last?.isEmpty == true }
            || items.contains { item in item.dropLast().contains("") }
        let children: [HTMLTag] = items.map { item in
            var content = blocks(item)
            if !loose, let flow = content.first as? InlineFlow, let paragraph = flow.children.first as? P {
                content[0] = InlineFlow(Fragment(children: paragraph.children))
                return content.count == 1 ? InlineFlow(Li(children: paragraph.children)) : Li(children: content)
            }
            return Li(children: content)
        }
        if first.ordered {
            let start = first.start == 1 ? [] : [Attribute(key: "start", value: String(first.start))]
            return Ol(attributes: start, children: children)
        }
        return Ul(children: children)
    }

    // Tables

    enum Alignment { case none, left, center, right }

    static func cells(_ line: String) -> [String] {
        var trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("|") { trimmed.removeFirst() }
        if trimmed.hasSuffix("|") && !trimmed.hasSuffix("\\|") { trimmed.removeLast() }
        var cells: [String] = []
        var current = ""
        var previous: Character?
        for character in trimmed {
            if character == "|" && previous != "\\" {
                cells.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(character)
            }
            previous = character
        }
        cells.append(current.trimmingCharacters(in: .whitespaces))
        return cells.map { $0.replacingOccurrences(of: "\\|", with: "|") }
    }

    static func tableSeparator(_ line: String) -> [Alignment]? {
        guard line.contains("-") else { return nil }
        let cells = cells(line)
        var alignments: [Alignment] = []
        for cell in cells {
            let dashes = cell.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            guard !dashes.isEmpty, dashes.allSatisfy({ $0 == "-" }) else { return nil }
            switch (cell.hasPrefix(":"), cell.hasSuffix(":")) {
            case (true, true): alignments.append(.center)
            case (true, false): alignments.append(.left)
            case (false, true): alignments.append(.right)
            case (false, false): alignments.append(.none)
            }
        }
        return alignments
    }

    mutating func table(_ lines: [String], from index: inout Int, alignments: [Alignment]) -> HTMLTag {
        func row(_ parser: inout BlockParser, _ line: String, header: Bool) -> HTMLTag {
            let values = Self.cells(line)
            let cells: [HTMLTag] = alignments.indices.map { column in
                let text = column < values.count ? values[column] : ""
                var attributes: [Attribute] = []
                switch alignments[column] {
                case .none: break
                case .left: attributes.append(Attribute(key: "style", value: "text-align: left"))
                case .center: attributes.append(Attribute(key: "style", value: "text-align: center"))
                case .right: attributes.append(Attribute(key: "style", value: "text-align: right"))
                }
                let children = parser.inline([text])
                return InlineFlow(header ? Th(attributes: attributes, children: children) : Td(attributes: attributes, children: children))
            }
            return Tr(children: cells)
        }

        let head = Thead(children: [row(&self, lines[index], header: true)])
        index += 2
        var body: [HTMLTag] = []
        while index < lines.count, lines[index].contains("|"), !lines[index].trimmingCharacters(in: .whitespaces).isEmpty {
            body.append(row(&self, lines[index], header: false))
            index += 1
        }
        return Table(children: [head] + (body.isEmpty ? [] : [Tbody(children: body)]))
    }

    // Raw HTML

    static func startsHTMLBlock(_ line: String) -> Bool {
        guard line.hasPrefix("<") else { return false }
        let name = line.dropFirst().drop { $0 == "/" }
        return name.first?.isLetter == true || line.hasPrefix("<!--")
    }

    // Inline

    func inline(_ lines: [String]) -> [HTMLTag] {
        var tags: [HTMLTag] = []
        for (offset, line) in lines.enumerated() {
            var text = line.trimmingCharacters(in: .whitespaces)
            let isLast = offset == lines.count - 1
            var hardBreak = false
            if !isLast {
                if line.hasSuffix("  ") {
                    hardBreak = true
                } else if text.hasSuffix("\\") {
                    text.removeLast()
                    hardBreak = true
                }
            }
            tags += InlineParser(options: options).parse(text)
            if !isLast {
                tags.append(hardBreak ? Br() : TextNode("\n"))
            }
        }
        return InlineParser.merged(tags)
    }
}

// MARK: - Inline

private struct InlineParser {
    let options: MarkdownOptions

    static let escapable = Set("\\`*_{}[]()#+-.!|~<>\"'")

    func parse(_ text: String) -> [HTMLTag] {
        let characters = Array(text)
        var tags: [HTMLTag] = []
        var buffer = ""
        var index = 0

        func emit() {
            if !buffer.isEmpty {
                tags.append(TextNode(buffer))
                buffer = ""
            }
        }

        while index < characters.count {
            let character = characters[index]
            if character == "\\", index + 1 < characters.count, Self.escapable.contains(characters[index + 1]) {
                buffer.append(characters[index + 1])
                index += 2
            } else if character == "`" {
                if let (tag, next) = codeSpan(characters, at: index) {
                    emit()
                    tags.append(tag)
                    index = next
                } else {
                    // An unmatched run of backticks is literal text, all of it.
                    let run = characters[index...].prefix { $0 == "`" }.count
                    buffer += String(repeating: "`", count: run)
                    index += run
                }
            } else if character == "!", index + 1 < characters.count, characters[index + 1] == "[",
                      let link = link(characters, at: index + 1) {
                emit()
                let image = Img(src: link.url, alt: Markdown.plainText(link.label))
                if let title = link.title { image.setAttribute(key: "title", value: title) }
                tags.append(image)
                index = link.end
            } else if character == "[", let link = link(characters, at: index) {
                emit()
                let anchor = A(href: link.url, children: parse(link.label))
                if let title = link.title { anchor.setAttribute(key: "title", value: title) }
                tags.append(anchor)
                index = link.end
            } else if character == "<", let (tag, next) = angle(characters, at: index) {
                emit()
                tags.append(tag)
                index = next
            } else if "*_~".contains(character), let (tag, next) = emphasis(characters, at: index) {
                emit()
                tags.append(tag)
                index = next
            } else {
                buffer.append(character)
                index += 1
            }
        }
        emit()
        return tags
    }

    /// Joins adjacent text nodes, so the output has no artificial seams.
    static func merged(_ tags: [HTMLTag]) -> [HTMLTag] {
        var result: [HTMLTag] = []
        for tag in tags {
            if let text = tag as? TextNode, let previous = result.last as? TextNode {
                result[result.count - 1] = TextNode.joined(previous, text)
            } else {
                result.append(tag)
            }
        }
        return result
    }

    func codeSpan(_ characters: [Character], at start: Int) -> (HTMLTag, Int)? {
        let run = characters[start...].prefix { $0 == "`" }.count
        var index = start + run
        while index < characters.count {
            if characters[index] == "`" {
                let closing = characters[index...].prefix { $0 == "`" }.count
                if closing == run {
                    var code = String(characters[(start + run)..<index])
                    if code.hasPrefix(" ") && code.hasSuffix(" ") && code.count > 1 {
                        code = String(code.dropFirst().dropLast())
                    }
                    return (Code(content: code), index + run)
                }
                index += closing
            } else {
                index += 1
            }
        }
        return nil
    }

    struct Link {
        let label: String
        let url: String
        let title: String?
        /// The index just past the closing `)`.
        let end: Int
    }

    /// `[label](url "title")`, starting at the `[`.
    func link(_ characters: [Character], at start: Int) -> Link? {
        var depth = 0
        var index = start
        var labelEnd: Int?
        while index < characters.count {
            switch characters[index] {
            case "\\": index += 1
            case "[": depth += 1
            case "]":
                depth -= 1
                if depth == 0 { labelEnd = index }
            default: break
            }
            if labelEnd != nil { break }
            index += 1
        }
        guard let end = labelEnd, end + 1 < characters.count, characters[end + 1] == "(" else { return nil }
        guard let close = destinationEnd(characters, from: end + 2) else { return nil }
        let inside = String(characters[(end + 2)..<close]).trimmingCharacters(in: .whitespaces)
        var url = inside
        var title: String?
        if let quote = inside.firstIndex(where: { $0 == "\"" }), quote != inside.startIndex, inside.hasSuffix("\""),
           quote != inside.index(before: inside.endIndex) {
            url = String(inside[..<quote]).trimmingCharacters(in: .whitespaces)
            title = String(inside[inside.index(after: quote)..<inside.index(before: inside.endIndex)])
        }
        if url.hasPrefix("<") && url.hasSuffix(">") {
            url = String(url.dropFirst().dropLast())
        }
        return Link(label: String(characters[(start + 1)..<end]), url: unescaped(url), title: title, end: close + 1)
    }

    /// The `)` that closes a link destination: parentheses inside it must balance, as in
    /// `/wiki/Swift_(programming_language)`, and a quoted title may hold any of them.
    func destinationEnd(_ characters: [Character], from start: Int) -> Int? {
        var depth = 0
        var inTitle = false
        var index = start
        while index < characters.count {
            let character = characters[index]
            if character == "\\" {
                index += 2
                continue
            }
            if inTitle {
                if character == "\"" { inTitle = false }
            } else if character == "\"", index > start, characters[index - 1].isWhitespace {
                inTitle = true
            } else if character == "(" {
                depth += 1
            } else if character == ")" {
                if depth == 0 { return index }
                depth -= 1
            }
            index += 1
        }
        return nil
    }

    /// Drops the backslash in front of escaped ASCII punctuation, so `/x\)y` links to `/x)y`.
    func unescaped(_ url: String) -> String {
        var result = ""
        var iterator = url.makeIterator()
        while let character = iterator.next() {
            if character == "\\", let next = iterator.next() {
                if !(next.isASCII && next.isPunctuation || next.isASCII && next.isSymbol) { result.append(character) }
                result.append(next)
            } else {
                result.append(character)
            }
        }
        return result
    }

    /// `<https://…>` autolinks and, with raw HTML on, inline tags.
    func angle(_ characters: [Character], at start: Int) -> (HTMLTag, Int)? {
        guard let close = characters[start...].firstIndex(of: ">") else { return nil }
        let inside = String(characters[(start + 1)..<close])
        let schemes = ["http://", "https://", "mailto:"]
        if schemes.contains(where: inside.hasPrefix), !inside.contains(" ") {
            return (A(href: inside, content: inside), close + 1)
        }
        if options.rawHTML, inside.drop(while: { $0 == "/" }).first?.isLetter == true {
            return (RawHTML(String(characters[start...close])), close + 1)
        }
        return nil
    }

    /// `*em*`, `_em_`, `**strong**`, `__strong__`, `~~del~~`.
    func emphasis(_ characters: [Character], at start: Int) -> (HTMLTag, Int)? {
        let marker = characters[start]
        let run = min(characters[start...].prefix { $0 == marker }.count, marker == "~" ? 2 : 3)
        guard marker != "~" || run == 2 else { return nil }
        let opensAfter = start + run
        guard opensAfter < characters.count, !characters[opensAfter].isWhitespace else { return nil }
        if marker == "_", start > 0, characters[start - 1].isLetter || characters[start - 1].isNumber { return nil }

        var index = opensAfter
        while index < characters.count {
            if characters[index] == "`", let (_, next) = codeSpan(characters, at: index) {
                index = next
                continue
            }
            guard characters[index] == marker else {
                index += 1
                continue
            }
            // Compare whole runs, so `*a **b** c*` closes on the last `*`, not inside `**`.
            let length = characters[index...].prefix { $0 == marker }.count
            let closes = length == run && !characters[index - 1].isWhitespace
                && !(marker == "_" && index + run < characters.count
                     && (characters[index + run].isLetter || characters[index + run].isNumber))
            if closes {
                let inner = parse(String(characters[opensAfter..<index]))
                let tag: HTMLTag
                switch (marker, run) {
                case ("~", _): tag = Del(children: inner)
                case (_, 1): tag = Em(children: inner)
                case (_, 2): tag = Strong(children: inner)
                default: tag = Em(children: [Strong(children: inner)])
                }
                return (tag, index + run)
            }
            index += length
        }
        return nil
    }
}
