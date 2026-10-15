import Foundation

#if canImport(Glibc)
import Glibc
private let socketStreamType = Int32(SOCK_STREAM.rawValue)

/// Writing to a socket the browser already closed must not kill the server with SIGPIPE.
private func sendNoSignal(_ socket: Int32, _ buffer: UnsafeRawPointer, _ length: Int) -> Int {
    send(socket, buffer, length, Int32(MSG_NOSIGNAL))
}
#else
import Darwin
private let socketStreamType = SOCK_STREAM

/// Writing to a socket the browser already closed must not kill the server with SIGPIPE.
private func sendNoSignal(_ socket: Int32, _ buffer: UnsafeRawPointer, _ length: Int) -> Int {
    var on: Int32 = 1
    setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &on, socklen_t(MemoryLayout<Int32>.size))
    return send(socket, buffer, length, 0)
}
#endif

/// The browsers waiting for a reload, as open Server-Sent Events connections.
///
/// The server thread subscribes connections; the watch loop calls ``broadcast()`` after a
/// successful rebuild. Each event is followed by closing the connection — the reloaded page opens
/// a new one.
final class ReloadHub: @unchecked Sendable {
    private let lock = NSLock()
    private var connections: [Int32] = []

    /// The number of browsers currently waiting.
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return connections.count
    }

    func subscribe(_ connection: Int32) {
        HTTPServer.send(Data(("HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\n"
            + "Cache-Control: no-store\r\nConnection: keep-alive\r\n\r\n: connected\n\n").utf8), to: connection)
        lock.lock()
        connections.append(connection)
        lock.unlock()
    }

    /// Tells every waiting browser to reload, and closes their connections.
    /// - Returns: How many browsers were told.
    @discardableResult
    func broadcast() -> Int {
        lock.lock()
        let waiting = connections
        connections.removeAll()
        lock.unlock()
        for connection in waiting {
            HTTPServer.send(Data("data: reload\n\n".utf8), to: connection)
            close(connection)
        }
        return waiting.count
    }
}

/// A single-threaded static file server, enough to preview a generated site.
///
/// Deliberately minimal: one connection at a time, `GET` only, no keep-alive. It exists so
/// `winged serve` does not need a dependency or a `python3 -m http.server` in the instructions.
struct HTTPServer: Sendable {
    let root: String
    let port: UInt16
    /// When set, HTML responses get a live-reload script and `/__winged/reload` streams events.
    var reloadHub: ReloadHub?

    static let reloadPath = "/__winged/reload"

    init(root: String, port: UInt16, reloadHub: ReloadHub? = nil) {
        self.root = root
        self.port = port
        self.reloadHub = reloadHub
    }

    enum ServerError: Error, CustomStringConvertible {
        case socketFailed
        case bindFailed(port: UInt16)
        case listenFailed

        var description: String {
            switch self {
            case .socketFailed: return "Could not open a socket."
            case .bindFailed(let port): return "Port \(port) is already in use."
            case .listenFailed: return "Could not listen on the socket."
            }
        }
    }

    func run() throws -> Never {
        serve(listener: try Self.bindListener(port: port))
    }

    /// Opens a listening socket on `port`, on every interface.
    static func bindListener(port: UInt16) throws -> Int32 {
        let listener = socket(AF_INET, socketStreamType, 0)
        guard listener >= 0 else { throw ServerError.socketFailed }

        var reuse: Int32 = 1
        setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

        var address = sockaddr_in()
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = port.bigEndian
        address.sin_addr = in_addr(s_addr: INADDR_ANY)

        let bound = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(listener, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bound >= 0 else {
            close(listener)
            throw ServerError.bindFailed(port: port)
        }
        guard listen(listener, 16) >= 0 else {
            close(listener)
            throw ServerError.listenFailed
        }
        return listener
    }

    /// Binds the first free port in `port..<port + attempts`, so a second `winged serve` does not
    /// fail just because 8000 is taken.
    static func bindFirstAvailable(from port: UInt16, attempts: Int = 20) throws -> (listener: Int32, port: UInt16) {
        var candidate = port
        for _ in 0..<max(attempts, 1) {
            if let listener = try? bindListener(port: candidate) {
                return (listener, candidate)
            }
            guard candidate < UInt16.max else { break }
            candidate += 1
        }
        throw ServerError.bindFailed(port: port)
    }

    /// Accepts connections forever on an already bound `listener`.
    func serve(listener: Int32) -> Never {
        while true {
            let connection = accept(listener, nil, nil)
            guard connection >= 0 else { continue }
            if !handle(connection) {
                close(connection)
            }
        }
    }

    /// Answers one request.
    /// - Returns: `true` when the connection was handed to the reload hub and must stay open.
    private func handle(_ connection: Int32) -> Bool {
        var buffer = [UInt8](repeating: 0, count: 4096)
        let bytesRead = recv(connection, &buffer, buffer.count, 0)
        guard bytesRead > 0,
              let request = String(bytes: buffer[0..<bytesRead], encoding: .utf8),
              let requestLine = request.split(separator: "\r\n").first else {
            return false
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" else {
            respond(connection, status: "405 Method Not Allowed", type: "text/plain", body: Data("Only GET is supported.".utf8))
            return false
        }

        let path = String(parts[1].split(separator: "?").first ?? "/")
        if let reloadHub, path == Self.reloadPath {
            reloadHub.subscribe(connection)
            return true
        }
        guard let resolved = resolve(path) else {
            respond(connection, status: "404 Not Found", type: "text/html", body: withReload(notFoundBody(for: path)))
            return false
        }

        guard let body = FileManager.default.contents(atPath: resolved) else {
            respond(connection, status: "500 Internal Server Error", type: "text/plain", body: Data())
            return false
        }
        let type = Self.contentType(of: resolved)
        respond(connection, status: "200 OK", type: type, body: type.hasPrefix("text/html") ? withReload(body) : body)
        return false
    }

    /// The script served pages get while live reload is on. It is never written to disk.
    static let reloadScript = "<script>new EventSource(\"\(reloadPath)\").onmessage = () => location.reload()</script>"

    private func withReload(_ html: Data) -> Data {
        reloadHub == nil ? html : Self.injectReloadScript(into: html)
    }

    /// Inserts ``reloadScript`` before the last `</body>`, or appends it.
    static func injectReloadScript(into html: Data) -> Data {
        guard var text = String(bytes: html, encoding: .utf8) else { return html }
        if let range = text.range(of: "</body>", options: [.backwards, .caseInsensitive]) {
            text.insert(contentsOf: reloadScript, at: range.lowerBound)
        } else {
            text += reloadScript
        }
        return Data(text.utf8)
    }

    /// The site's own `404.html` when it has one — what static hosts serve — otherwise a short
    /// message naming the missing path.
    func notFoundBody(for path: String) -> Data {
        FileManager.default.contents(atPath: URL(fileURLWithPath: root).appendingPathComponent("404.html").path)
            ?? Data("<h1>404</h1><p>\(path) is not in \(root)</p>".utf8)
    }

    /// Maps a URL path to a file inside the served directory, refusing to escape it.
    func resolve(_ path: String) -> String? {
        let rootURL = URL(fileURLWithPath: root).standardizedFileURL
        let decoded = path.removingPercentEncoding ?? path
        var candidate = rootURL.appendingPathComponent(decoded).standardizedFileURL

        guard candidate.path == rootURL.path || candidate.path.hasPrefix(rootURL.path + "/") else {
            return nil
        }

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDirectory),
           isDirectory.boolValue {
            candidate = candidate.appendingPathComponent("index.html")
        }

        return FileManager.default.fileExists(atPath: candidate.path) ? candidate.path : nil
    }

    fileprivate static func send(_ data: Data, to connection: Int32) {
        data.withUnsafeBytes { raw in
            var sent = 0
            while sent < raw.count {
                let written = sendNoSignal(connection, raw.baseAddress!.advanced(by: sent), raw.count - sent)
                if written <= 0 { return }
                sent += written
            }
        }
    }

    private func respond(_ connection: Int32, status: String, type: String, body: Data) {
        var response = Data("HTTP/1.1 \(status)\r\n".utf8)
        response.append(Data("Content-Type: \(type)\r\n".utf8))
        response.append(Data("Content-Length: \(body.count)\r\n".utf8))
        response.append(Data("Cache-Control: no-store\r\n".utf8))
        response.append(Data("Connection: close\r\n\r\n".utf8))
        response.append(body)
        Self.send(response, to: connection)
    }

    private static let contentTypes = [
        "html": "text/html; charset=utf-8",
        "htm": "text/html; charset=utf-8",
        "css": "text/css; charset=utf-8",
        "js": "text/javascript; charset=utf-8",
        "mjs": "text/javascript; charset=utf-8",
        "json": "application/json",
        "xml": "application/xml",
        "svg": "image/svg+xml",
        "png": "image/png",
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "webp": "image/webp",
        "avif": "image/avif",
        "gif": "image/gif",
        "ico": "image/x-icon",
        "woff2": "font/woff2",
        "woff": "font/woff",
        "mp4": "video/mp4",
        "txt": "text/plain; charset=utf-8"
    ]

    static func contentType(of path: String) -> String {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        return contentTypes[ext] ?? "application/octet-stream"
    }
}
