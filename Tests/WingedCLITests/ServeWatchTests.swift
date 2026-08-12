import Foundation
import Testing
@testable import WingedCLI

/// The watcher is a snapshot comparison: if two snapshots differ, the site is rebuilt.
@Suite final class ServeWatchTests {
    private let root: URL
    private let serve: Serve

    init() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-watch-tests-\(UUID().uuidString)")
        serve = try Serve.parse([])

        try FileManager.default.createDirectory(at: root.appendingPathComponent("Sources"),
                                                withIntermediateDirectories: true)
        try "let a = 1".write(to: root.appendingPathComponent("Sources/main.swift"),
                              atomically: true, encoding: .utf8)
        try "// manifest".write(to: root.appendingPathComponent("Package.swift"),
                                atomically: true, encoding: .utf8)
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    private var watched: [String] {
        ["Sources", "Package.swift"].map { root.appendingPathComponent($0).path }
    }

    @Test func snapshotsEveryFileItWatches() {
        let snapshot = serve.signature(of: watched)

        #expect(snapshot.count == 2)
        #expect(snapshot.keys.contains { $0.hasSuffix("Sources/main.swift") })
        #expect(snapshot.keys.contains { $0.hasSuffix("Package.swift") })
    }

    @Test func aStableTreeProducesAStableSnapshot() {
        #expect(serve.signature(of: watched) == serve.signature(of: watched))
    }

    @Test func editingAFileChangesTheSnapshot() throws {
        let before = serve.signature(of: watched)

        let source = root.appendingPathComponent("Sources/main.swift")
        try "let a = 2".write(to: source, atomically: true, encoding: .utf8)
        // Rewriting is not enough on filesystems with coarse timestamps.
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(5)],
                                              ofItemAtPath: source.path)

        #expect(serve.signature(of: watched) != before)
    }

    @Test func addingAFileChangesTheSnapshot() throws {
        let before = serve.signature(of: watched)

        try "let b = 1".write(to: root.appendingPathComponent("Sources/extra.swift"),
                              atomically: true, encoding: .utf8)

        let after = serve.signature(of: watched)
        #expect(after != before)
        #expect(after.count == before.count + 1)
    }

    @Test func missingPathsAreSkippedRatherThanCrashing() {
        let snapshot = serve.signature(of: [root.appendingPathComponent("assets").path])

        #expect(snapshot.isEmpty)
    }
}

@Suite struct ShellTests {

    @Test func capturesStandardOutput() throws {
        let output = try Shell.capture(["echo", "hello"], in: FileManager.default.currentDirectoryPath)

        #expect(output.trimmingCharacters(in: .whitespacesAndNewlines) == "hello")
    }

    @Test func runsInTheGivenDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.path
        let output = try Shell.capture(["pwd"], in: directory)

        #expect(output.contains("tmp") || output.contains(directory))
    }

    @Test func throwsOnFailureAndKeepsTheOutput() {
        #expect(throws: Shell.Failure.self) {
            try Shell.capture(["sh", "-c", "echo boom; exit 3"], in: FileManager.default.currentDirectoryPath)
        }
    }

    @Test func describesAnExitCode() {
        let failure = Shell.Failure(command: "swift run Site", status: 3, output: "boom")

        #expect(failure.description.contains("failed with status 3"))
        #expect(failure.description.contains("boom"))
    }

    /// The message that cost an afternoon: SIGKILL used to print as if it were an exit code.
    @Test func describesASignalAsASignal() {
        let failure = Shell.Failure(command: "swift run Site", status: 9, output: "", wasSignalled: true)

        #expect(failure.description.contains("killed by signal 9"))
        #expect(failure.description.contains("SIGKILL"))
        #expect(!failure.description.contains("failed with status"))
    }
}
