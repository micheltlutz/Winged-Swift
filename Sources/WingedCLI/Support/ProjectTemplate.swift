import ArgumentParser
import Foundation

/// A project skeleton bundled with the CLI: which template files go where.
struct ProjectTemplate {
    let name: String
    let summary: String
    /// Template paths (relative to `Templates/`) and their destinations; destinations may contain
    /// `{{PROJECT_NAME}}`.
    let files: [(source: String, destination: String)]
    /// The source tree shown in the generated AGENTS.md.
    let tree: String

    static let defaultName = "landing"

    static let all: [ProjectTemplate] = [
        ProjectTemplate(
            name: "minimal",
            summary: "One page and a layout, in a single file.",
            files: [("minimal/main.swift.template", "Sources/{{PROJECT_NAME}}/main.swift")],
            tree: tree("Sources/{{PROJECT_NAME}}/", [
                ("└── main.swift", "the Site, its page and its layout — and publish()")
            ])),
        ProjectTemplate(
            name: "landing",
            summary: "A marketing page with a hero, feature cards and an About page.",
            files: [("landing/main.swift.template", "Sources/{{PROJECT_NAME}}/main.swift"),
                    ("landing/Pages.swift.template", "Sources/{{PROJECT_NAME}}/Pages.swift"),
                    ("landing/SiteLayout.swift.template", "Sources/{{PROJECT_NAME}}/SiteLayout.swift"),
                    ("landing/Components.swift.template", "Sources/{{PROJECT_NAME}}/Components.swift")],
            tree: tree("Sources/{{PROJECT_NAME}}/", [
                ("├── main.swift", "the Site: name, URL, pages, layout — and publish()"),
                ("├── Pages.swift", "one `Page` type per page"),
                ("├── SiteLayout.swift", "the shell shared by every page (head extras, nav, footer)"),
                ("└── Components.swift", "content data + reusable markup")
            ])),
        ProjectTemplate(
            name: "blog",
            summary: "A post list, one page per post under /posts/, and an RSS feed.",
            files: [("blog/main.swift.template", "Sources/{{PROJECT_NAME}}/main.swift"),
                    ("blog/Posts.swift.template", "Sources/{{PROJECT_NAME}}/Posts.swift"),
                    ("blog/Pages.swift.template", "Sources/{{PROJECT_NAME}}/Pages.swift"),
                    ("blog/SiteLayout.swift.template", "Sources/{{PROJECT_NAME}}/SiteLayout.swift")],
            tree: tree("Sources/{{PROJECT_NAME}}/", [
                ("├── main.swift", "the Site: pages (one per post), feed items — and publish()"),
                ("├── Posts.swift", "the posts, as data"),
                ("├── Pages.swift", "Home (post list), PostPage, About"),
                ("└── SiteLayout.swift", "the shell shared by every page")
            ])),
        ProjectTemplate(
            name: "docs",
            summary: "Documentation with a sidebar of sections and one page per topic.",
            files: [("docs/main.swift.template", "Sources/{{PROJECT_NAME}}/main.swift"),
                    ("docs/Docs.swift.template", "Sources/{{PROJECT_NAME}}/Docs.swift")],
            tree: tree("Sources/{{PROJECT_NAME}}/", [
                ("├── main.swift", "the Site: one page per topic — and publish()"),
                ("└── Docs.swift", "sections and topics as data, DocPage, the sidebar layout")
            ]))
    ]

    /// Lines up the comments of a source tree for AGENTS.md.
    static func tree(_ root: String, _ entries: [(path: String, comment: String)]) -> String {
        let width = max((entries.map(\.path.count).max() ?? 0) + 2, 24)
        return ([root] + entries.map { entry in
            entry.path.padding(toLength: width, withPad: " ", startingAt: 0) + "# " + entry.comment
        }).joined(separator: "\n")
    }

    static func named(_ name: String) -> ProjectTemplate? {
        all.first { $0.name == name }
    }

    /// The files every bundled template shares.
    static func sharedFiles(tailwind: Bool) -> [(source: String, destination: String)] {
        var files = [("shared/Package.swift.template", "Package.swift"),
                     ("shared/AGENTS.md.template", "AGENTS.md"),
                     ("shared/gitignore.template", ".gitignore")]
        if tailwind {
            files += [("shared/tailwind.input.css.template", "assets/css/tailwind.input.css"),
                      ("shared/tailwind.config.ts.template", "tailwind.config.ts"),
                      ("shared/package.json.template", "package.json")]
        } else {
            files.append(("shared/style.css.template", "assets/css/style.css"))
        }
        return files
    }

    /// The `--list-templates` output.
    static var listing: String {
        let width = all.map(\.name.count).max() ?? 0
        return all.map { template in
            let marker = template.name == defaultName ? " (default)" : ""
            let name = template.name.padding(toLength: width + 2, withPad: " ", startingAt: 0)
            return " " + " " + name + template.summary + marker
        }.joined(separator: "\n")
    }
}

/// A starter fetched with git: `--template https://github.com/you/starter`.
///
/// The repository is cloned shallowly, its `.git` removed, and every UTF-8 file — and every path —
/// gets the same `{{PLACEHOLDER}}` substitution as the bundled templates. An optional
/// `winged-template.json` (`{"message": "…"}`) is printed after creation and removed.
enum RemoteTemplate {
    static func isRemote(_ template: String) -> Bool {
        template.hasPrefix("https://") || template.hasPrefix("file://")
    }

    /// Clones `url` into `destination` and applies the placeholders.
    /// - Returns: The template's post-create message, if it has one.
    @discardableResult
    static func create(from url: String, at destination: URL, placeholders: [String: String]) throws -> String? {
        guard isRemote(url) else {
            throw ValidationError("Remote templates must be https:// (or file:// for a local repository).")
        }
        let parent = destination.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        do {
            _ = try Shell.capture(["git", "clone", "--quiet", "--depth", "1", url, destination.path], in: parent.path)
        } catch {
            throw ValidationError("Could not clone \(url): \(error)")
        }
        try FileManager.default.removeItem(at: destination.appendingPathComponent(".git"))
        try substitute(in: destination, placeholders: placeholders)

        let manifest = destination.appendingPathComponent("winged-template.json")
        guard let data = FileManager.default.contents(atPath: manifest.path) else { return nil }
        try FileManager.default.removeItem(at: manifest)
        let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        return object?["message"] as? String
    }

    /// Replaces placeholders in file contents and in file and directory names, deepest first.
    static func substitute(in root: URL, placeholders: [String: String]) throws {
        let paths = (FileManager.default.subpaths(atPath: root.path) ?? [])
            .sorted { $0.split(separator: "/").count > $1.split(separator: "/").count }
        for relative in paths {
            let url = root.appendingPathComponent(relative)
            if let data = FileManager.default.contents(atPath: url.path),
               let text = String(bytes: data, encoding: .utf8) {
                let replaced = Scaffolder.fill(text, with: placeholders)
                if replaced != text {
                    try replaced.write(to: url, atomically: true, encoding: .utf8)
                }
            }
            let name = url.lastPathComponent
            let renamed = Scaffolder.fill(name, with: placeholders)
            if renamed != name {
                try FileManager.default.moveItem(at: url, to: url.deletingLastPathComponent().appendingPathComponent(renamed))
            }
        }
    }
}
