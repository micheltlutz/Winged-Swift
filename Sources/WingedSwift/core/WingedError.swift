import Foundation

/// An error thrown while writing a site to disk.
///
/// ``StaticSiteGenerator`` throws only this type, so a build script can switch on what went wrong.
/// The underlying Foundation error is kept for diagnostics.
///
/// ## Example
/// ```swift
/// do {
///     try generator.copyAsset(from: "./assets/css", to: "css")
/// } catch .assetNotFound(let path) {
///     print("Missing asset folder: \(path)")
/// } catch {
///     print(error)
/// }
/// ```
public enum WingedError: Error, Sendable, CustomStringConvertible {
    /// The source of ``StaticSiteGenerator/copyAsset(from:to:)`` does not exist.
    case assetNotFound(path: String)
    /// A directory could not be created.
    case directoryCreationFailed(path: String, underlying: any Error)
    /// A file could not be written.
    case writeFailed(path: String, underlying: any Error)
    /// A file or directory could not be copied.
    case copyFailed(source: String, destination: String, underlying: any Error)
    /// A file or directory could not be removed.
    case removeFailed(path: String, underlying: any Error)

    public var description: String {
        switch self {
        case .assetNotFound(let path):
            return "Asset not found: \(path)"
        case .directoryCreationFailed(let path, let underlying):
            return "Could not create directory \(path): \(underlying.localizedDescription)"
        case .writeFailed(let path, let underlying):
            return "Could not write \(path): \(underlying.localizedDescription)"
        case .copyFailed(let source, let destination, let underlying):
            return "Could not copy \(source) to \(destination): \(underlying.localizedDescription)"
        case .removeFailed(let path, let underlying):
            return "Could not remove \(path): \(underlying.localizedDescription)"
        }
    }
}
