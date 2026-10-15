import Foundation

/// The `---`-delimited `key: value` header of a Markdown file.
///
/// ```markdown
/// ---
/// title: Hello, world
/// date: 2026-10-15
/// tags: swift, web
/// published: true
/// ---
/// # The body starts here
/// ```
///
/// Values may be quoted (`"…"` or `'…'`); `tags` accepts `a, b` or `[a, b]`; lines starting with
/// `#` are comments. Unknown keys are kept in ``values`` for your own use.
public struct FrontMatter: Sendable, Equatable {
    /// Every key and its raw value, in no particular order.
    public var values: [String: String]

    /// Creates front matter from values.
    ///
    /// - Parameter values: Keys and raw values.
    public init(values: [String: String] = [:]) {
        self.values = values
    }

    /// The raw value for `key`.
    public subscript(key: String) -> String? {
        values[key]
    }

    /// `title`.
    public var title: String? { values["title"] }
    /// `description` (or `summary`).
    public var description: String? { values["description"] ?? values["summary"] }
    /// `author`.
    public var author: String? { values["author"] }
    /// `image`, for social cards.
    public var image: String? { values["image"] }
    /// `path`, overriding the path derived from the file name.
    public var path: String? { values["path"] }
    /// `tags`, as a list.
    public var tags: [String] {
        guard var raw = values["tags"] else { return [] }
        if raw.hasPrefix("[") && raw.hasSuffix("]") {
            raw = String(raw.dropFirst().dropLast())
        }
        return raw.split(separator: ",").map { Self.unquoted($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }
    }
    /// `published`; anything but `false` / `no` / `0` counts as published.
    public var published: Bool {
        guard let raw = values["published"]?.lowercased() else { return true }
        return !["false", "no", "0"].contains(raw)
    }
    /// `date`, accepting `2026-10-15`, `2026-10-15 09:30` and full ISO 8601. Dates without a zone
    /// are UTC.
    public var date: Date? {
        values["date"].flatMap(Self.parseDate)
    }

    static func parseDate(_ raw: String) -> Date? {
        if let date = ISO8601DateFormatter().date(from: raw) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        for format in ["yyyy-MM-dd", "yyyy-MM-dd HH:mm", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm:ss"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                return date
            }
        }
        return nil
    }

    static func unquoted(_ value: String) -> String {
        for quote in ["\"", "'"] where value.count >= 2 && value.hasPrefix(quote) && value.hasSuffix(quote) {
            return String(value.dropFirst().dropLast())
        }
        return value
    }

    /// Separates the front matter from the body.
    ///
    /// - Parameters:
    ///   - source: The whole file. Without a leading `---` line, the front matter is empty and the
    ///     body is the whole source.
    ///   - file: The file name, used in error messages.
    /// - Returns: The front matter and the remaining Markdown.
    /// - Throws: ``WingedError/invalidFrontMatter(file:line:reason:)`` for a missing closing `---`,
    ///   a line without `key: value`, or a `date` that cannot be read.
    public static func split(_ source: String, file: String = "<input>") throws(WingedError)
        -> (frontMatter: FrontMatter, body: String) {
        let lines = source.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return (FrontMatter(), source)
        }
        var values: [String: String] = [:]
        for (offset, line) in lines.enumerated().dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" {
                let matter = FrontMatter(values: values)
                if let raw = values["date"], matter.date == nil {
                    throw .invalidFrontMatter(file: file, line: offset, reason: "cannot read the date \"\(raw)\"")
                }
                return (matter, lines[(offset + 1)...].joined(separator: "\n"))
            }
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            guard let colon = trimmed.firstIndex(of: ":"), colon != trimmed.startIndex else {
                throw .invalidFrontMatter(file: file, line: offset + 1, reason: "expected `key: value`")
            }
            let key = trimmed[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            let value = trimmed[trimmed.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            values[key] = unquoted(value)
        }
        throw .invalidFrontMatter(file: file, line: lines.count, reason: "missing the closing ---")
    }
}
