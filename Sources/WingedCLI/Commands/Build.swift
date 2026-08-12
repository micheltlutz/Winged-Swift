import ArgumentParser
import Foundation

struct Build: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate the site into the output directory."
    )

    @Option(name: .shortAndLong, help: "The output directory.")
    var output: String = "dist"

    @Option(name: .shortAndLong, help: "The project directory.")
    var path: String = "."

    @Flag(help: "Build in release configuration.")
    var release = false

    func run() throws {
        try Self.build(projectPath: path, output: output, release: release)
    }

    /// Builds the site and reports what was written. Shared with `winged serve --watch`.
    @discardableResult
    static func build(projectPath: String, output: String, release: Bool) throws -> String {
        let product = try executableProduct(in: projectPath)

        Log.step("Building \(product)")
        // An absolute path, so the site lands in the project rather than wherever the user stood.
        let outputURL = URL(fileURLWithPath: projectPath)
            .appendingPathComponent(output)
            .standardizedFileURL

        let configuration = release ? ["-c", "release"] : []

        // Build, then execute the product directly rather than going through `swift run`.
        // One less process in the chain, no rebuild check between building and running — and
        // `swift run` spawned from here is killed outright by some macOS environments.
        try Shell.run(["swift", "build"] + configuration, in: projectPath)

        let binPath = try Shell.capture(["swift", "build", "--show-bin-path"] + configuration,
                                        in: projectPath)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let executable = URL(fileURLWithPath: binPath).appendingPathComponent(product).path

        guard FileManager.default.isExecutableFile(atPath: executable) else {
            throw ValidationError("Built \(product), but no executable at \(executable).")
        }

        try Shell.run([executable, outputURL.path], in: projectPath)

        let pages = (try? FileManager.default.subpathsOfDirectory(atPath: outputURL.path))?
            .filter { $0.hasSuffix(".html") } ?? []
        Log.success("\(pages.count) page(s) in \(output)/")
        return outputURL.path
    }

    /// Reads the first executable product from the package manifest.
    static func executableProduct(in projectPath: String) throws -> String {
        let json = try Shell.capture(["swift", "package", "dump-package"], in: projectPath)
        guard let data = json.data(using: .utf8),
              let manifest = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let products = manifest["products"] as? [[String: Any]] else {
            throw ValidationError("Could not read Package.swift in \(projectPath).")
        }

        for product in products {
            let isExecutable = (product["type"] as? [String: Any])?["executable"] != nil
            if isExecutable, let name = product["name"] as? String {
                return name
            }
        }

        // A single executable target without an explicit product is the common scaffold shape.
        if let targets = manifest["targets"] as? [[String: Any]],
           let target = targets.first(where: { $0["type"] as? String == "executable" }),
           let name = target["name"] as? String {
            return name
        }

        throw ValidationError("No executable product found in \(projectPath)/Package.swift.")
    }
}
