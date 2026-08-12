import Foundation
import Testing
@testable import WingedCLI

@Suite struct HTTPServerContentTypeTests {

    @Test func mapsTheTypesABrowserActuallyNeeds() {
        #expect(HTTPServer.contentType(of: "/dist/index.html") == "text/html; charset=utf-8")
        #expect(HTTPServer.contentType(of: "/dist/css/style.css") == "text/css; charset=utf-8")
        #expect(HTTPServer.contentType(of: "/dist/js/app.js") == "text/javascript; charset=utf-8")
        #expect(HTTPServer.contentType(of: "/dist/sitemap.xml") == "application/xml")
        #expect(HTTPServer.contentType(of: "/dist/img/logo.svg") == "image/svg+xml")
        #expect(HTTPServer.contentType(of: "/dist/img/hero.webp") == "image/webp")
        #expect(HTTPServer.contentType(of: "/dist/fonts/inter.woff2") == "font/woff2")
        #expect(HTTPServer.contentType(of: "/dist/robots.txt") == "text/plain; charset=utf-8")
    }

    @Test func isCaseInsensitive() {
        #expect(HTTPServer.contentType(of: "/IMG/Photo.JPEG") == "image/jpeg")
    }

    @Test func fallsBackForUnknownAndMissingExtensions() {
        #expect(HTTPServer.contentType(of: "/dist/archive.tar") == "application/octet-stream")
        #expect(HTTPServer.contentType(of: "/dist/LICENSE") == "application/octet-stream")
    }
}

/// The path resolver is the server's only security boundary, so it gets its own suite.
@Suite final class HTTPServerResolveTests {
    private let root: URL
    private let server: HTTPServer

    init() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-serve-tests-\(UUID().uuidString)")
        server = HTTPServer(root: root.path, port: 0)

        let manager = FileManager.default
        try manager.createDirectory(at: root.appendingPathComponent("about"),
                                    withIntermediateDirectories: true)
        try "<h1>home</h1>".write(to: root.appendingPathComponent("index.html"),
                                 atomically: true, encoding: .utf8)
        try "<h1>about</h1>".write(to: root.appendingPathComponent("about/index.html"),
                                   atomically: true, encoding: .utf8)
        try "secret".write(to: root.appendingPathComponent("../winged-outside-\(UUID().uuidString).txt"),
                           atomically: true, encoding: .utf8)
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    @Test func servesTheIndexForTheRoot() throws {
        #expect(server.resolve("/") == root.appendingPathComponent("index.html").path)
    }

    @Test func servesTheIndexOfASubdirectory() throws {
        #expect(server.resolve("/about/") == root.appendingPathComponent("about/index.html").path)
        #expect(server.resolve("/about") == root.appendingPathComponent("about/index.html").path)
    }

    @Test func servesAFileDirectly() throws {
        #expect(server.resolve("/index.html") == root.appendingPathComponent("index.html").path)
    }

    @Test func decodesPercentEncoding() throws {
        let name = "a file.html"
        try "<h1>spaces</h1>".write(to: root.appendingPathComponent(name),
                                    atomically: true, encoding: .utf8)

        #expect(server.resolve("/a%20file.html") == root.appendingPathComponent(name).path)
    }

    @Test func refusesToEscapeTheServedDirectory() throws {
        #expect(server.resolve("/../Package.swift") == nil)
        #expect(server.resolve("/about/../../etc/passwd") == nil)
        #expect(server.resolve("/%2e%2e/%2e%2e/etc/passwd") == nil)
    }

    @Test func returnsNilForMissingFiles() throws {
        #expect(server.resolve("/nope.html") == nil)
        #expect(server.resolve("/about/missing/") == nil)
    }
}

@Suite struct HTTPServerErrorTests {

    @Test func refusesToStartOnATakenPort() async throws {
        let port = UInt16.random(in: 20_000...60_000)
        let root = FileManager.default.temporaryDirectory.path

        // Hold the port with a first server, then a second one must fail rather than hang.
        let thread = Thread { try? HTTPServer(root: root, port: port).run() }
        thread.stackSize = 512 * 1024
        thread.start()
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(throws: HTTPServer.ServerError.self) {
            try HTTPServer(root: root, port: port).run()
        }
    }

    @Test func namesWhatWentWrong() {
        #expect(HTTPServer.ServerError.socketFailed.description.contains("socket"))
        #expect(HTTPServer.ServerError.bindFailed(port: 8000).description.contains("8000"))
        #expect(HTTPServer.ServerError.bindFailed(port: 8000).description.contains("already in use"))
        #expect(HTTPServer.ServerError.listenFailed.description.contains("listen"))
    }
}
