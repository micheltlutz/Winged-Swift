import Foundation
import Testing
@testable import WingedCLI

@Suite final class ScaffolderTests {
    private let root: URL

    init() {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-new-tests-\(UUID().uuidString)")
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    private func makeScaffolder() -> Scaffolder {
        Scaffolder(root: root, placeholders: [
            "PROJECT_NAME": "DemoSite",
            "PROJECT_SLUG": "demo-site",
            "SITE_TITLE": "Demo Site",
            "SITE_DESCRIPTION": "A demo",
            "SITE_LANG": "pt-BR",
            "YEAR": "2026",
            "WINGED_VERSION": "2.0.0"
        ])
    }

    private func read(_ relativePath: String) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    @Test func substitutesEveryPlaceholder() throws {
        try makeScaffolder().write("Package.swift.template", to: "Package.swift")

        let manifest = try read("Package.swift")
        #expect(manifest.contains("name: \"DemoSite\""))
        #expect(manifest.contains("from: \"2.0.0\""))
        #expect(!manifest.contains("{{"))
    }

    @Test func createsIntermediateDirectories() throws {
        try makeScaffolder().write("main.swift.template", to: "Sources/DemoSite/main.swift")

        let source = try read("Sources/DemoSite/main.swift")
        #expect(source.contains("Demo Site"))
        #expect(source.contains("StaticSiteGenerator"))
    }

    @Test func scaffoldedLayoutUsesTheDocumentAPI() throws {
        try makeScaffolder().write("SiteLayout.swift.template", to: "SiteLayout.swift")

        let layout = try read("SiteLayout.swift")
        #expect(layout.contains("Document(lang: \"pt-BR\")"))
        #expect(!layout.contains("{{"))
    }

    @Test func shipsAgentInstructionsWithTheProject() throws {
        try makeScaffolder().write("AGENTS.md.template", to: "AGENTS.md")

        let agents = try read("AGENTS.md")
        #expect(agents.contains("# AGENTS.md — DemoSite"))
        #expect(agents.contains("Never edit `dist/`"))
        #expect(!agents.contains("{{"))
    }

    @Test func failsLoudlyOnAMissingTemplate() {
        #expect(throws: (any Error).self) {
            try makeScaffolder().write("does-not-exist.template", to: "nope.txt")
        }
    }
}
