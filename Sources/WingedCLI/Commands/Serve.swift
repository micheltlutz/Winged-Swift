import ArgumentParser
import Foundation

struct Serve: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Serve the generated site locally, optionally rebuilding and reloading on change."
    )

    @Option(name: .shortAndLong, help: "The port to listen on; the next free one is used if it is taken.")
    var port: UInt16 = 8000

    @Option(name: .shortAndLong, help: "The directory to serve.")
    var output: String = "dist"

    @Option(help: "The project directory.")
    var path: String = "."

    @Flag(name: .shortAndLong, help: "Rebuild whenever a source or asset file changes, and reload the browser.")
    var watch = false

    @Flag(help: "Do not inject the live-reload script while watching.")
    var noReload = false

    @Flag(help: "Open the site in the default browser.")
    var open = false

    @Flag(help: "Skip the initial build and serve whatever is already there.")
    var noBuild = false

    @Flag(help: "Do not run the package.json build:css script after each build.")
    var skipCSS = false

    func run() throws {
        if !noBuild {
            try Build.build(projectPath: path, output: output, release: false, css: !skipCSS)
        }

        let served = URL(fileURLWithPath: path).appendingPathComponent(output).path
        guard FileManager.default.fileExists(atPath: served) else {
            throw ValidationError("\(served) does not exist. Run `winged build` first.")
        }

        let hub = watch && !noReload ? ReloadHub() : nil
        let (listener, chosenPort) = try HTTPServer.bindFirstAvailable(from: port)
        let server = HTTPServer(root: served, port: chosenPort, reloadHub: hub)
        let thread = Thread { server.serve(listener: listener) }
        thread.stackSize = 512 * 1024
        thread.start()

        let url = "http://localhost:\(chosenPort)"
        if chosenPort != port {
            Log.warning("Port \(port) is in use — using \(chosenPort).")
        }
        Log.success("Serving \(output)/ on \(url)")
        if let lan = Network.lanAddress() {
            Log.detail("On your network: http://\(lan):\(chosenPort)")
        }
        Log.detail(watch ? "Watching for changes\(hub == nil ? "" : " with live reload") — Ctrl-C to stop." : "Ctrl-C to stop.")
        if open {
            _ = try? Shell.run(Browser.openCommand(for: url), in: path)
        }

        guard watch else {
            dispatchMain()
        }

        watchAndRebuild(hub: hub)
    }

    /// Rebuilds whenever ``FileWatcher`` reports a change under the sources or the assets.
    private func watchAndRebuild(hub: ReloadHub?) -> Never {
        let watcher = FileWatcher(paths: ["Sources", "assets", "Package.swift"]
            .map { URL(fileURLWithPath: path).appendingPathComponent($0).path })

        var lastSnapshot = watcher.snapshot()
        while true {
            Thread.sleep(forTimeInterval: 0.5)
            let current = watcher.snapshot()
            guard current != lastSnapshot else { continue }
            lastSnapshot = current

            do {
                try Build.build(projectPath: path, output: output, release: false, css: !skipCSS)
                if let hub {
                    let reloaded = hub.broadcast()
                    Log.detail(reloaded == 0 ? "Rebuilt." : "Reloaded \(reloaded) page(s).")
                } else {
                    Log.detail("Reload the page to see the change.")
                }
            } catch {
                Log.failure("\(error)")
            }
        }
    }
}
