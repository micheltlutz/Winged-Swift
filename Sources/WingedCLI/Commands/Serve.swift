import ArgumentParser
import Foundation

struct Serve: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Serve the generated site locally, optionally rebuilding on change."
    )

    @Option(name: .shortAndLong, help: "The port to listen on.")
    var port: UInt16 = 8000

    @Option(name: .shortAndLong, help: "The directory to serve.")
    var output: String = "dist"

    @Option(help: "The project directory.")
    var path: String = "."

    @Flag(name: .shortAndLong, help: "Rebuild whenever a source or asset file changes.")
    var watch = false

    @Flag(help: "Skip the initial build and serve whatever is already there.")
    var noBuild = false

    func run() throws {
        if !noBuild {
            try Build.build(projectPath: path, output: output, release: false)
        }

        let served = URL(fileURLWithPath: path).appendingPathComponent(output).path
        guard FileManager.default.fileExists(atPath: served) else {
            throw ValidationError("\(served) does not exist. Run `winged build` first.")
        }

        let server = HTTPServer(root: served, port: port)
        let thread = Thread {
            do {
                try server.run()
            } catch {
                print("❌ \(error)")
                Foundation.exit(1)
            }
        }
        thread.stackSize = 512 * 1024
        thread.start()

        Log.success("Serving \(output)/ on http://localhost:\(port)")
        Log.detail(watch ? "Watching for changes — Ctrl-C to stop." : "Ctrl-C to stop.")

        guard watch else {
            dispatchMain()
        }

        watchAndRebuild()
    }

    /// Rebuilds whenever ``FileWatcher`` reports a change under the sources or the assets.
    private func watchAndRebuild() -> Never {
        let watcher = FileWatcher(paths: ["Sources", "assets", "Package.swift"]
            .map { URL(fileURLWithPath: path).appendingPathComponent($0).path })

        var lastSnapshot = watcher.snapshot()
        while true {
            Thread.sleep(forTimeInterval: 0.5)
            let current = watcher.snapshot()
            guard current != lastSnapshot else { continue }
            lastSnapshot = current

            do {
                try Build.build(projectPath: path, output: output, release: false)
                Log.detail("Reload the page to see the change.")
            } catch {
                print("❌ \(error)")
            }
        }
    }
}
