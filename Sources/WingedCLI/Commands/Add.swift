import ArgumentParser
import Foundation

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Add a page or a component to a WingedSwift site.",
        discussion: """
        winged add page Pricing — writes Sources/<Target>/Pages/Pricing.swift
        winged add component PriceCard — writes Sources/<Target>/Components/PriceCard.swift
        """
    )

    enum Kind: String, ExpressibleByArgument, CaseIterable {
        case page, component
    }

    @Argument(help: "What to add: page or component.")
    var kind: Kind

    @Argument(help: "The type name, in UpperCamelCase (Pricing, PriceCard).")
    var name: String

    @Option(help: "The project directory.")
    var path: String = "."

    @Option(help: "The source target. Defaults to the only folder in Sources/ with a main.swift.")
    var target: String?

    func run() throws {
        let file = try Generator.write(kind: kind, name: name, projectPath: path, target: target)
        Log.success("Created \(file)")
        if kind == .page {
            Log.detail("List it in `pages` in main.swift: \(name)()")
        }
    }

    /// The file generation, separated from argument parsing so it can be tested directly.
    enum Generator {
        static func write(kind: Kind, name: String, projectPath: String, target: String?) throws -> String {
            guard let first = name.first, first.isUppercase, first.isLetter,
                  name.allSatisfy({ $0.isLetter || $0.isNumber }) else {
                throw ValidationError("\(name) is not an UpperCamelCase type name.")
            }
            let target = try target ?? mainTarget(in: projectPath)
            let folder = kind == .page ? "Pages" : "Components"
            let relative = "Sources/\(target)/\(folder)/\(name).swift"
            let url = URL(fileURLWithPath: projectPath).appendingPathComponent(relative)
            guard !FileManager.default.fileExists(atPath: url.path) else {
                throw ValidationError("\(relative) already exists.")
            }
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try source(kind: kind, name: name).write(to: url, atomically: true, encoding: .utf8)
            return relative
        }

        /// The folder in `Sources/` that holds `main.swift`, when there is exactly one.
        static func mainTarget(in projectPath: String) throws -> String {
            let sources = URL(fileURLWithPath: projectPath).appendingPathComponent("Sources")
            let folders = (try? FileManager.default.contentsOfDirectory(atPath: sources.path)) ?? []
            let candidates = folders.sorted().filter {
                FileManager.default.fileExists(atPath: sources.appendingPathComponent("\($0)/main.swift").path)
            }
            guard candidates.count == 1 else {
                throw ValidationError(candidates.isEmpty
                    ? "No Sources/<Target>/main.swift in \(projectPath) — is this a WingedSwift site?"
                    : "Several targets have a main.swift (\(candidates.joined(separator: ", "))); pass --target.")
            }
            return candidates[0]
        }

        static func source(kind: Kind, name: String) -> String {
            switch kind {
            case .page:
                return """
                import WingedSwift

                /// Served at /\(Page.slug(name))/ — set `path` to change it.
                struct \(name): Page {
                    var title = "\(Page.title(name))"
                    var description = ""

                    var body: HTMLTag {
                        Section {
                            H1(content: title)
                            P(content: "Write the \(Page.title(name).lowercased()) page here.")
                        }
                    }
                }

                """
            case .component:
                return """
                import WingedSwift

                struct \(name): Component {
                    var body: HTMLTag {
                        Div {
                            P(content: "\(name)")
                        }
                        .addClass("\(Page.slug(name))")
                    }
                }

                """
            }
        }
    }

    /// Mirrors the library's slug rule, so the comment in a generated page states the real path.
    enum Page {
        static func slug(_ name: String) -> String {
            words(name).map { $0.lowercased() }.joined(separator: "-")
        }

        static func title(_ name: String) -> String {
            words(name).joined(separator: " ")
        }

        private static func words(_ name: String) -> [String] {
            var name = name
            if name.hasSuffix("Page") && name.count > 4 {
                name.removeLast(4)
            }
            var words: [String] = []
            var previous: Character?
            for character in name {
                if character.isUppercase, let previous, previous.isLowercase || previous.isNumber {
                    words.append("")
                }
                if words.isEmpty {
                    words.append("")
                }
                words[words.count - 1].append(character)
                previous = character
            }
            return words
        }
    }
}
