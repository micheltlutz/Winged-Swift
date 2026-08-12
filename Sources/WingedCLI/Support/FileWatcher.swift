import Foundation

/// Detects changes under a set of paths by comparing modification-time snapshots.
///
/// Polling rather than FSEvents/inotify keeps the behaviour identical on macOS and Linux, and half
/// a second of latency is invisible next to a Swift compile.
struct FileWatcher {
    /// The files and directories to watch. Missing entries are skipped, so a project without an
    /// `assets/` folder watches the rest without complaining.
    let paths: [String]

    /// The modification date of every watched file, keyed by absolute path.
    func snapshot() -> [String: Date] {
        var result: [String: Date] = [:]
        let manager = FileManager.default

        for path in paths {
            var isDirectory: ObjCBool = false
            guard manager.fileExists(atPath: path, isDirectory: &isDirectory) else { continue }

            if isDirectory.boolValue {
                for relative in manager.subpaths(atPath: path) ?? [] {
                    let full = "\(path)/\(relative)"
                    if let date = modificationDate(of: full) {
                        result[full] = date
                    }
                }
            } else if let date = modificationDate(of: path) {
                result[path] = date
            }
        }
        return result
    }

    /// True when anything watched was added, removed or touched since `snapshot`.
    func hasChanged(since snapshot: [String: Date]) -> Bool {
        self.snapshot() != snapshot
    }

    private func modificationDate(of path: String) -> Date? {
        (try? FileManager.default.attributesOfItem(atPath: path))?[.modificationDate] as? Date
    }
}
