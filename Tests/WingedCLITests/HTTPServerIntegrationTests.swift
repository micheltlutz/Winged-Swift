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

    struct Reply {
        let status: Int
        let contentType: String
        let cacheControl: String
        let body: String
    }

    /// The listener needs a moment; retry rather than sleeping a fixed amount.
    private func get(_ path: String, method: String = "GET", attempts: Int = 40) async throws -> Reply {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(port)\(path)")!)
        request.httpMethod = method
        var lastError: (any Error)?

        for _ in 0..<attempts {
            do {
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return Reply(status: http.statusCode,
                             contentType: http.value(forHTTPHeaderField: "Content-Type") ?? "",
                             cacheControl: http.value(forHTTPHeaderField: "Cache-Control") ?? "",
                             body: String(data: data, encoding: .utf8) ?? "")
            } catch {
                lastError = error
                try await Task.sleep(nanoseconds: 50_000_000)
            }
        }
        throw lastError ?? URLError(.cannotConnectToHost)
    }

    @Test func servesTheIndexForTheRoot() async throws {
        let reply = try await get("/")

        #expect(reply.status == 200)
        #expect(reply.contentType == "text/html; charset=utf-8")
        #expect(reply.body.contains("<h1>home</h1>"))
    }

    @Test func servesASubdirectoryIndex() async throws {
        let reply = try await get("/about/")

        #expect(reply.status == 200)
        #expect(reply.body.contains("<h1>about</h1>"))
    }

    @Test func servesAssetsWithTheRightContentType() async throws {
        let reply = try await get("/css/style.css")

        #expect(reply.status == 200)
        #expect(reply.contentType == "text/css; charset=utf-8")
        #expect(reply.body == "body { margin: 0; }")
    }

    @Test func ignoresTheQueryString() async throws {
        let reply = try await get("/index.html?v=2")

        #expect(reply.status == 200)
        #expect(reply.body.contains("<h1>home</h1>"))
    }

    @Test func answers404ForMissingFiles() async throws {
        let reply = try await get("/nope.html")

        #expect(reply.status == 404)
        #expect(reply.body.contains("404"))
    }

    @Test func refusesToServeFilesOutsideTheRoot() async throws {
        let reply = try await get("/../../etc/passwd")

        #expect(reply.status == 404)
    }

    @Test func rejectsMethodsOtherThanGET() async throws {
        let reply = try await get("/", method: "POST")

        #expect(reply.status == 405)
    }

    @Test func doesNotCacheSoTheWatchLoopIsVisible() async throws {
        let reply = try await get("/")

        #expect(reply.cacheControl == "no-store")
    }
}
