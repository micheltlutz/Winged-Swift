import ArgumentParser
import Foundation
import Testing
@testable import WingedCLI

/// `winged build` has one piece of real logic: finding which product to run.
@Suite final class ExecutableProductTests {
    private let root: URL

    init() {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-build-tests-\(UUID().uuidString)")
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    private func makePackage(named name: String, manifest: String) throws -> String {
        let directory = root.appendingPathComponent(name)
        try FileManager.default.createDirectory(
            at: directory.appendingPathComponent("Sources/\(name)"),
            withIntermediateDirectories: true
        )
        try manifest.write(to: directory.appendingPathComponent("Package.swift"),
                           atomically: true, encoding: .utf8)
        try "print(\"hi\")".write(to: directory.appendingPathComponent("Sources/\(name)/main.swift"),
                                  atomically: true, encoding: .utf8)
        return directory.path
    }

    @Test func findsAnExplicitExecutableProduct() throws {
        let path = try makePackage(named: "Explicit", manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "Explicit",
            products: [.executable(name: "ExplicitSite", targets: ["Explicit"])],
            targets: [.executableTarget(name: "Explicit")]
        )
        """)

        #expect(try Build.executableProduct(in: path) == "ExplicitSite")
    }

    @Test func fallsBackToTheExecutableTargetWhenNoProductIsDeclared() throws {
        // The shape `winged new` scaffolds: a target, no explicit product.
        let path = try makePackage(named: "Implicit", manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "Implicit",
            targets: [.executableTarget(name: "Implicit")]
        )
        """)

        #expect(try Build.executableProduct(in: path) == "Implicit")
    }

    @Test func ignoresLibraryProducts() throws {
        let path = try makePackage(named: "Mixed", manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "Mixed",
            products: [
                .library(name: "MixedLib", targets: ["Mixed"]),
                .executable(name: "MixedSite", targets: ["Mixed"])
            ],
            targets: [.executableTarget(name: "Mixed")]
        )
        """)

        #expect(try Build.executableProduct(in: path) == "MixedSite")
    }

    @Test func throwsWhenThereIsNothingToRun() throws {
        let path = try makePackage(named: "LibraryOnly", manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "LibraryOnly",
            products: [.library(name: "LibraryOnly", targets: ["LibraryOnly"])],
            targets: [.target(name: "LibraryOnly")]
        )
        """)

        #expect(throws: (any Error).self) {
            try Build.executableProduct(in: path)
        }
    }

    @Test func throwsWhenThereIsNoPackageAtAll() {
        #expect(throws: (any Error).self) {
            try Build.executableProduct(in: root.appendingPathComponent("nowhere").path)
        }
    }

    /// A dependency-free package that stands in for a site generator: it writes a page into the
    /// directory it is given, which is exactly the contract `winged build` relies on.
    private func makeGeneratorPackage(named name: String) throws -> String {
        let path = try makePackage(named: name, manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "\(name)",
            targets: [.executableTarget(name: "\(name)")]
        )
        """)

        try """
        import Foundation

        let output = CommandLine.arguments[1]
        try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
        try "<!DOCTYPE html>\\n<h1>built</h1>".write(toFile: output + "/index.html",
                                                    atomically: true, encoding: .utf8)
        """.write(to: URL(fileURLWithPath: path).appendingPathComponent("Sources/\(name)/main.swift"),
                  atomically: true, encoding: .utf8)
        return path
    }

    /// Compiles and runs a real package the way `winged build` does.
    @Test func buildsAndRunsTheProductWritingToTheOutputDirectory() throws {
        let path = try makeGeneratorPackage(named: "Generator")

        let outputPath = try Build.build(projectPath: path, output: "dist", release: false)

        #expect(outputPath == URL(fileURLWithPath: path).appendingPathComponent("dist").path)
        let page = try String(contentsOfFile: outputPath + "/index.html", encoding: .utf8)
        #expect(page.contains("<h1>built</h1>"))
    }

    @Test func theCommandItselfBuildsIntoTheRequestedDirectory() throws {
        let path = try makeGeneratorPackage(named: "Commanded")

        var command = try Build.parse(["--path", path, "--output", "site"])
        try command.run()

        let page = URL(fileURLWithPath: path).appendingPathComponent("site/index.html")
        #expect(FileManager.default.fileExists(atPath: page.path))
    }

    /// Note: this test makes `swift build` print real compiler errors into the test log.
    /// They are expected — the package below is deliberately not valid Swift.
    @Test func buildFailsLoudlyWhenTheSourceDoesNotCompile() throws {
        let path = try makePackage(named: "Broken", manifest: """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "Broken",
            targets: [.executableTarget(name: "Broken")]
        )
        """)

        try "this is not swift".write(
            to: URL(fileURLWithPath: path).appendingPathComponent("Sources/Broken/main.swift"),
            atomically: true, encoding: .utf8
        )

        #expect(throws: (any Error).self) {
            try Build.build(projectPath: path, output: "dist", release: false)
        }
    }
}
