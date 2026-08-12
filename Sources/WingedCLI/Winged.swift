import ArgumentParser

@main
struct Winged: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "winged",
        abstract: "Scaffold, build and preview static sites written with WingedSwift.",
        version: "2.0.0",
        subcommands: [New.self, Build.self, Serve.self],
        defaultSubcommand: Build.self
    )
}
