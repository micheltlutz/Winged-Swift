import Foundation

#if canImport(Glibc)
import Glibc
private let socketStreamType = Int32(SOCK_STREAM.rawValue)
#else
import Darwin
private let socketStreamType = SOCK_STREAM
#endif

/// A single-threaded static file server, enough to preview a generated site.
///
/// Deliberately minimal: one connection at a time, `GET` only, no keep-alive. It exists so
/// `winged serve` does not need a dependency or a `python3 -m http.server` in the instructions.
struct HTTPServer: Sendable {
    let root: String
    let port: UInt16

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

        while true {
            let connection = accept(listener, nil, nil)
            guard connection >= 0 else { continue }
            handle(connection)
            close(connection)
        }
    }

    private func handle(_ connection: Int32) {
        var buffer = [UInt8](repeating: 0, count: 4096)
        let bytesRead = recv(connection, &buffer, buffer.count, 0)
        guard bytesRead > 0,
              let request = String(bytes: buffer[0..<bytesRead], encoding: .utf8),
              let requestLine = request.split(separator: "\r\n").first else {
            return
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" else {
            respond(connection, status: "405 Method Not Allowed", type: "text/plain", body: Data("Only GET is supported.".utf8))
            return
        }

        let path = String(parts[1].split(separator: "?").first ?? "/")
        guard let resolved = resolve(path) else {
            respond(connection, status: "404 Not Found", type: "text/html",
                    body: Data("<h1>404</h1><p>\(path) is not in \(root)</p>".utf8))
            return
        }

        guard let body = FileManager.default.contents(atPath: resolved) else {
            respond(connection, status: "500 Internal Server Error", type: "text/plain", body: Data())
            return
        }
        respond(connection, status: "200 OK", type: Self.contentType(of: resolved), body: body)
    }

    /// Maps a URL path to a file inside the served directory, refusing to escape it.
    private func resolve(_ path: String) -> String? {
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

    private func respond(_ connection: Int32, status: String, type: String, body: Data) {
        var response = Data("HTTP/1.1 \(status)\r\n".utf8)
        response.append(Data("Content-Type: \(type)\r\n".utf8))
        response.append(Data("Content-Length: \(body.count)\r\n".utf8))
        response.append(Data("Cache-Control: no-store\r\n".utf8))
        response.append(Data("Connection: close\r\n\r\n".utf8))
        response.append(body)

        response.withUnsafeBytes { raw in
            var sent = 0
            while sent < raw.count {
                let written = send(connection, raw.baseAddress!.advanced(by: sent), raw.count - sent, 0)
                if written <= 0 { return }
                sent += written
            }
        }
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
