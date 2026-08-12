import Foundation
import Testing
@testable import WingedCLI

// URLSession lives in a separate module in swift-corelibs-foundation.
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Drives the real server over a real socket: bind, accept, parse, respond.
///
/// The request handling is what `winged serve` is, so it is worth testing for real rather than
/// only unit-testing the helpers it calls.
@Suite(.serialized) final class HTTPServerIntegrationTests {
    private let root: URL
    private let port: UInt16
    private let session = URLSession(configuration: .ephemeral)

    init() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("winged-http-tests-\(UUID().uuidString)")
        port = UInt16.random(in: 20_000...60_000)

        let manager = FileManager.default
        try manager.createDirectory(at: root.appendingPathComponent("about"),
                                    withIntermediateDirectories: true)
        try manager.createDirectory(at: root.appendingPathComponent("css"),
                                    withIntermediateDirectories: true)
        try "<!DOCTYPE html>\n<h1>home</h1>".write(to: root.appendingPathComponent("index.html"),
                                                   atomically: true, encoding: .utf8)
        try "<h1>about</h1>".write(to: root.appendingPathComponent("about/index.html"),
                                   atomically: true, encoding: .utf8)
        try "body { margin: 0; }".write(to: root.appendingPathComponent("css/style.css"),
                                        atomically: true, encoding: .utf8)

        let server = HTTPServer(root: root.path, port: port)
        let thread = Thread { try? server.run() }
        thread.stackSize = 512 * 1024
        thread.start()
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }

    /// The listener needs a moment; retry rather than sleeping a fixed amount.
    private func get(_ path: String, attempts: Int = 40) async throws -> (Int, String, String) {
        let url = URL(string: "http://127.0.0.1:\(port)\(path)")!
        var lastError: (any Error)?

        for _ in 0..<attempts {
            do {
                let (data, response) = try await session.data(from: url)
                let http = response as! HTTPURLResponse
                return (http.statusCode,
                        http.value(forHTTPHeaderField: "Content-Type") ?? "",
                        String(data: data, encoding: .utf8) ?? "")
            } catch {
                lastError = error
                try await Task.sleep(nanoseconds: 50_000_000)
            }
        }
        throw lastError ?? URLError(.cannotConnectToHost)
    }

    @Test func servesTheIndexForTheRoot() async throws {
        let (status, type, body) = try await get("/")

        #expect(status == 200)
        #expect(type == "text/html; charset=utf-8")
        #expect(body.contains("<h1>home</h1>"))
    }

    @Test func servesASubdirectoryIndex() async throws {
        let (status, _, body) = try await get("/about/")

        #expect(status == 200)
        #expect(body.contains("<h1>about</h1>"))
    }

    @Test func servesAssetsWithTheRightContentType() async throws {
        let (status, type, body) = try await get("/css/style.css")

        #expect(status == 200)
        #expect(type == "text/css; charset=utf-8")
        #expect(body == "body { margin: 0; }")
    }

    @Test func ignoresTheQueryString() async throws {
        let (status, _, body) = try await get("/index.html?v=2")

        #expect(status == 200)
        #expect(body.contains("<h1>home</h1>"))
    }

    @Test func answers404ForMissingFiles() async throws {
        let (status, _, body) = try await get("/nope.html")

        #expect(status == 404)
        #expect(body.contains("404"))
    }

    @Test func refusesToServeFilesOutsideTheRoot() async throws {
        let (status, _, _) = try await get("/../../etc/passwd")

        #expect(status == 404)
    }

    @Test func rejectsMethodsOtherThanGET() async throws {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)/")!)
        request.httpMethod = "POST"

        _ = try await get("/")   // make sure the listener is up first
        let (_, response) = try await session.data(for: request)

        #expect((response as! HTTPURLResponse).statusCode == 405)
    }

    @Test func doesNotCacheSoTheWatchLoopIsVisible() async throws {
        _ = try await get("/")
        let (_, response) = try await session.data(from: URL(string: "http://127.0.0.1:\(port)/")!)

        #expect((response as! HTTPURLResponse).value(forHTTPHeaderField: "Cache-Control") == "no-store")
    }
}
