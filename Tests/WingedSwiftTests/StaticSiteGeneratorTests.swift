import Foundation
import Testing
@testable import WingedSwift

/// A class suite so each test gets a fresh temporary directory in `init` and removes it in `deinit`.
@Suite final class StaticSiteGeneratorTests {
    private let outputDirectory: String
    private let generator: StaticSiteGenerator

    init() {
        outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-swift-tests-\(UUID().uuidString)")
            .path
        generator = StaticSiteGenerator(outputDirectory: outputDirectory)
    }

    deinit {
        try? FileManager.default.removeItem(atPath: outputDirectory)
    }

    private func read(_ path: String) throws -> String {
        try String(contentsOfFile: "\(outputDirectory)/\(path)", encoding: .utf8)
    }

    @Test func generateWritesDoctypeAndMarkup() throws {
        let page = html {
            Head(children: [Title(content: "Home")])
            Body(children: [H1(content: "Hello")])
        }

        try generator.generate(page: page, to: "index.html")

        let written = try read("index.html")
        #expect(written.hasPrefix("<!DOCTYPE html>\n"))
        #expect(written.contains("<title>Home</title>"))
        #expect(written.contains("<h1>Hello</h1>"))
    }

    @Test func generateWritesADocument() throws {
        let page = Document(lang: "pt-BR") {
            Title(content: "Início")
        } body: {
            H1(content: "Olá")
        }

        try generator.generate(document: page, to: "index.html")

        let written = try read("index.html")
        #expect(written.hasPrefix("<!DOCTYPE html>\n<html lang=\"pt-BR\">"))
        #expect(written.contains("<h1>Olá</h1>"))
    }

    @Test func generateMultipleDocuments() throws {
        let home = Document { Title(content: "Home") } body: { H1(content: "Home") }
        let about = Document { Title(content: "About") } body: { H1(content: "About") }

        try generator.generateMultiple(documents: [
            (document: home, path: "index.html"),
            (document: about, path: "about/index.html")
        ])

        #expect(try read("index.html").contains("<h1>Home</h1>"))
        #expect(try read("about/index.html").contains("<h1>About</h1>"))
    }

    @Test func generateCreatesNestedDirectories() throws {
        let page = html { Body(children: [P(content: "Post")]) }

        try generator.generate(page: page, to: "blog/2026/post.html")

        #expect(FileManager.default.fileExists(atPath: "\(outputDirectory)/blog/2026/post.html"))
    }

    @Test func generateCanSkipDoctype() throws {
        try generator.generate(page: Div(content: "partial"), to: "partial.html", doctype: false)

        #expect(!(try read("partial.html").contains("<!DOCTYPE html>")))
    }

    @Test func generateMultipleWritesEveryPage() throws {
        try generator.generateMultiple([
            (page: html { Body(children: [H1(content: "Home")]) }, path: "index.html"),
            (page: html { Body(children: [H1(content: "About")]) }, path: "about.html")
        ])

        #expect(try read("index.html").contains("Home"))
        #expect(try read("about.html").contains("About"))
    }

    @Test func writeFileAndCopyAsset() throws {
        try generator.writeFile(content: "User-agent: *\nAllow: /", to: "robots.txt")
        #expect(try read("robots.txt") == "User-agent: *\nAllow: /")

        let source = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-asset-\(UUID().uuidString).css")
        try "body { margin: 0; }".write(to: source, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: source) }

        try generator.copyAsset(from: source.path, to: "css/style.css")
        #expect(try read("css/style.css") == "body { margin: 0; }")

        // Copying again must overwrite instead of throwing.
        try generator.copyAsset(from: source.path, to: "css/style.css")
        #expect(try read("css/style.css") == "body { margin: 0; }")
    }

    @Test func cleanRemovesPreviousOutput() throws {
        try generator.writeFile(content: "stale", to: "old.html")

        try generator.clean()

        #expect(!FileManager.default.fileExists(atPath: "\(outputDirectory)/old.html"))
        #expect(FileManager.default.fileExists(atPath: outputDirectory))
    }
}
