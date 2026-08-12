import ArgumentParser
import Foundation

struct New: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create a new WingedSwift site project."
    )

    @Argument(help: "The name of the project (also the SwiftPM target name).")
    var name: String

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

    func run() throws {
        let destination = path ?? "./\(name)"
        let root = URL(fileURLWithPath: destination)

        guard !FileManager.default.fileExists(atPath: root.path) else {
            throw ValidationError("\(root.path) already exists.")
        }

        let year = Calendar.current.component(.year, from: Date())
        let placeholders = [
            "PROJECT_NAME": name,
            "PROJECT_SLUG": name.lowercased().replacingOccurrences(of: " ", with: "-"),
            "SITE_TITLE": title ?? name,
            "SITE_DESCRIPTION": description,
            "SITE_LANG": lang,
            "YEAR": String(year),
            "WINGED_VERSION": Winged.configuration.version
        ]

        let scaffolder = Scaffolder(root: root, placeholders: placeholders)

        Log.step("Creating \(name) in \(root.path)")

        try scaffolder.write("Package.swift.template", to: "Package.swift")
        try scaffolder.write("main.swift.template", to: "Sources/\(name)/main.swift")
        try scaffolder.write("SiteLayout.swift.template", to: "Sources/\(name)/SiteLayout.swift")
        try scaffolder.write("Components.swift.template", to: "Sources/\(name)/Components.swift")
        try scaffolder.write("AGENTS.md.template", to: "AGENTS.md")
        try scaffolder.write("gitignore.template", to: ".gitignore")

        if tailwind {
            try scaffolder.write("tailwind.input.css.template", to: "assets/css/tailwind.input.css")
            try scaffolder.write("tailwind.config.ts.template", to: "tailwind.config.ts")
            try scaffolder.write("package.json.template", to: "package.json")
        } else {
            try scaffolder.write("style.css.template", to: "assets/css/style.css")
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
            Log.warning("Tailwind: run `npm install`, then `winged build && npm run build:css`.")
            Log.detail("Tailwind scans dist/, so the site must be generated before the CSS.")
        }
    }
}

/// Copies bundled templates, substituting `{{PLACEHOLDER}}` tokens.
struct Scaffolder {
    let root: URL
    let placeholders: [String: String]

    func write(_ template: String, to relativePath: String) throws {
        guard let url = Bundle.module.url(forResource: "Templates/\(template)", withExtension: nil)
                ?? Bundle.module.url(forResource: template, withExtension: nil, subdirectory: "Templates") else {
            throw ValidationError("Missing bundled template \(template).")
        }

        var contents = try String(contentsOf: url, encoding: .utf8)
        for (key, value) in placeholders {
            contents = contents.replacingOccurrences(of: "{{\(key)}}", with: value)
        }

        let destination = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.write(to: destination, atomically: true, encoding: .utf8)
        Log.detail("+ \(relativePath)")
    }
}
