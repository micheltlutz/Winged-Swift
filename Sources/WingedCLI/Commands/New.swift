import ArgumentParser
import Foundation

struct New: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create a new WingedSwift site project."
    )

    @Argument(help: "The name of the project (also the SwiftPM target name).")
    var name: String?

    @Option(name: .shortAndLong, help: "Where to create the project. Defaults to ./<name>.")
    var path: String?

    @Option(help: "The title shown on the site. Defaults to the project name.")
    var title: String?

    @Option(help: "The site description used in the SEO meta tags.")
    var description: String = "A static site built with Swift."

    @Option(help: "The document language.")
    var lang: String = "en"

    @Flag(help: "Set the project up for Tailwind CSS instead of plain CSS.")
    var tailwind = false

    @Option(name: .shortAndLong,
            help: "A bundled template (minimal, landing, blog, docs) or a git URL (https://…).")
    var template: String = ProjectTemplate.defaultName

    @Flag(help: "List the bundled templates and exit.")
    var listTemplates = false

    func run() throws {
        if listTemplates {
            print(ProjectTemplate.listing)
            return
        }
        guard let name else {
            throw ValidationError("Missing the project name: winged new <name>")
        }
        let destination = path ?? "./\(name)"
        let root = URL(fileURLWithPath: destination)

        guard !FileManager.default.fileExists(atPath: root.path) else {
            throw ValidationError("\(root.path) already exists.")
        }

        let year = Calendar.current.component(.year, from: Date())
        let today = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
        let placeholders = [
            "PROJECT_NAME": name,
            "PROJECT_SLUG": name.lowercased().replacingOccurrences(of: " ", with: "-"),
            "SITE_TITLE": title ?? name,
            "SITE_DESCRIPTION": description,
            "SITE_LANG": lang,
            "YEAR": String(year),
            "TODAY": today,
            "WINGED_VERSION": Winged.configuration.version
        ]

        Log.step("Creating \(name) in \(root.path)")

        if RemoteTemplate.isRemote(template) {
            let message = try RemoteTemplate.create(from: template, at: root, placeholders: placeholders)
            Log.success("Project created from \(template)")
            if let message {
                Log.detail(message)
            }
            return
        }

        guard let project = ProjectTemplate.named(template) else {
            throw ValidationError("Unknown template \(template). Available:\n\(ProjectTemplate.listing)")
        }
        let scaffolder = Scaffolder(root: root, placeholders: placeholders.merging(
            ["SOURCE_TREE": Scaffolder.fill(project.tree, with: placeholders)]) { $1 })
        for file in ProjectTemplate.sharedFiles(tailwind: tailwind) + project.files {
            try scaffolder.write(file.source, to: Scaffolder.fill(file.destination, with: placeholders))
        }

        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("assets/images"),
            withIntermediateDirectories: true
        )

        Log.success("Project created")
        Log.detail("cd \(destination)")
        Log.detail("winged serve --watch")
        if tailwind {
            Log.detail("")
            Log.warning("Tailwind: run `npm install` once — `winged build` then runs `npm run build:css` itself.")
        }
    }
}

/// Copies bundled templates, substituting `{{PLACEHOLDER}}` tokens.
struct Scaffolder {
    let root: URL
    let placeholders: [String: String]

    /// Replaces every `{{KEY}}` in `text`.
    static func fill(_ text: String, with placeholders: [String: String]) -> String {
        placeholders.reduce(text) { $0.replacingOccurrences(of: "{{\($1.key)}}", with: $1.value) }
    }

    func write(_ template: String, to relativePath: String) throws {
        let directory = ("Templates/" + template as NSString).deletingLastPathComponent
        let file = (template as NSString).lastPathComponent
        guard let url = Bundle.module.url(forResource: file, withExtension: nil, subdirectory: directory)
                ?? Bundle.module.url(forResource: "Templates/\(template)", withExtension: nil) else {
            throw ValidationError("Missing bundled template \(template).")
        }

        let contents = Self.fill(try String(contentsOf: url, encoding: .utf8), with: placeholders)

        let destination = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.write(to: destination, atomically: true, encoding: .utf8)
        Log.detail("+ \(relativePath)")
    }
}
