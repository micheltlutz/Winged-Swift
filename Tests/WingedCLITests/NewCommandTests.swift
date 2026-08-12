import ArgumentParser
import Foundation
import Testing
@testable import WingedCLI

/// Runs `winged new` for real and inspects what it wrote.
@Suite final class NewCommandTests {
    private let root: URL

    init() {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-new-command-tests-\(UUID().uuidString)")
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    private func scaffold(_ arguments: [String]) throws -> URL {
        let destination = root.appendingPathComponent("Site")
        var command = try New.parse(arguments + ["--path", destination.path])
        try command.run()
        return destination
    }

    private func read(_ url: URL, _ path: String) throws -> String {
        try String(contentsOf: url.appendingPathComponent(path), encoding: .utf8)
    }

    @Test func writesAWorkingProjectLayout() throws {
        let site = try scaffold(["DemoSite", "--title", "Demo Site", "--description", "A demo"])

        for path in ["Package.swift",
                     "Sources/DemoSite/main.swift",
                     "Sources/DemoSite/SiteLayout.swift",
                     "Sources/DemoSite/Components.swift",
                     "AGENTS.md",
                     ".gitignore",
                     "assets/css/style.css"] {
            #expect(FileManager.default.fileExists(atPath: site.appendingPathComponent(path).path),
                    "missing \(path)")
        }

        var isDirectory: ObjCBool = false
        #expect(FileManager.default.fileExists(atPath: site.appendingPathComponent("assets/images").path,
                                               isDirectory: &isDirectory))
        #expect(isDirectory.boolValue)
    }

    @Test func leavesNoPlaceholderBehind() throws {
        let site = try scaffold(["DemoSite", "--title", "Demo Site"])

        let files = FileManager.default.subpaths(atPath: site.path) ?? []
        for file in files {
            let url = site.appendingPathComponent(file)
            guard let contents = try? String(contentsOf: url, encoding: .utf8) else { continue }
            #expect(!contents.contains("{{"), "\(file) still contains a placeholder")
        }
    }

    @Test func carriesTheOptionsIntoTheGeneratedSource() throws {
        let site = try scaffold(["DemoSite", "--title", "Demo Site",
                                 "--description", "Motorcycles", "--lang", "pt-BR"])

        #expect(try read(site, "Sources/DemoSite/main.swift").contains("Demo Site"))
        #expect(try read(site, "Sources/DemoSite/main.swift").contains("Motorcycles"))
        #expect(try read(site, "Sources/DemoSite/SiteLayout.swift").contains("Document(lang: \"pt-BR\")"))
        #expect(try read(site, "Package.swift").contains("name: \"DemoSite\""))
    }

    @Test func plainProjectsHaveNoTailwindFiles() throws {
        let site = try scaffold(["DemoSite"])

        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent("package.json").path))
        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent("tailwind.config.ts").path))
        #expect(FileManager.default.fileExists(atPath: site.appendingPathComponent("assets/css/style.css").path))
    }

    @Test func tailwindProjectsSwapTheStylesheetSetup() throws {
        let site = try scaffold(["DemoSite", "--tailwind"])

        #expect(FileManager.default.fileExists(atPath: site.appendingPathComponent("package.json").path))
        #expect(try read(site, "tailwind.config.ts").contains("./dist/**/*.html"))
        #expect(try read(site, "assets/css/tailwind.input.css").contains("@tailwind base"))
        // The handwritten stylesheet would fight Tailwind's build.
        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent("assets/css/style.css").path))
    }

    @Test func refusesToOverwriteAnExistingDirectory() throws {
        _ = try scaffold(["DemoSite"])

        #expect(throws: (any Error).self) {
            _ = try scaffold(["DemoSite"])
        }
    }
}
