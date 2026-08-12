import Foundation

enum Shell {
    struct Failure: Error, CustomStringConvertible {
        let command: String
        let status: Int32
        let output: String
        var wasSignalled = false

        var description: String {
            // A signal is worth naming: status 9 reads like an exit code, but it means the
            // process was killed from outside — usually the OS reclaiming memory.
            let reason = wasSignalled
                ? "was killed by signal \(status)\(status == SIGKILL ? " (SIGKILL — often the OS running out of memory)" : "")"
                : "failed with status \(status)"
            return "`\(command)` \(reason)\n\(output)"
        }
    }

    /// Runs a command, streaming its output to the terminal.
    @discardableResult
    static func run(_ arguments: [String], in directory: String) throws -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw Failure(command: arguments.joined(separator: " "),
                          status: process.terminationStatus,
                          output: "",
                          wasSignalled: process.terminationReason == .uncaughtSignal)
        }
        return process.terminationStatus
    }

    /// Runs a command and captures its standard output.
    static func capture(_ arguments: [String], in directory: String) throws -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: directory)
        process.standardOutput = pipe
        process.standardError = Pipe()
        try process.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let output = String(data: data, encoding: .utf8) ?? ""

        guard process.terminationStatus == 0 else {
            throw Failure(command: arguments.joined(separator: " "),
                          status: process.terminationStatus,
                          output: output,
                          wasSignalled: process.terminationReason == .uncaughtSignal)
        }
        return output
    }
}

enum Log {
    static func step(_ message: String) { print("▶ \(message)") }
    static func success(_ message: String) { print("✅ \(message)") }
    static func warning(_ message: String) { print("⚠️  \(message)") }
    static func detail(_ message: String) { print("   \(message)") }
}
