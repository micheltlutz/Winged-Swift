import ArgumentParser
import Foundation
import Testing
@testable import WingedCLI

#if canImport(Glibc)
import Glibc
private let streamType = Int32(SOCK_STREAM.rawValue)
#else
import Darwin
private let streamType = SOCK_STREAM
#endif

private func temporaryDirectory(_ label: String) throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("winged-\(label)-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

private func read(_ url: URL, _ path: String) throws -> String {
    try String(contentsOf: url.appendingPathComponent(path), encoding: .utf8)
}

private func git(_ arguments: [String], in directory: URL) throws -> String {
    try Shell.capture(["git", "-c", "user.name=test", "-c", "user.email=test@localhost",
                       "-c", "init.defaultBranch=main"] + arguments, in: directory.path)
}

/// Reads from a socket until `marker` arrives or the peer closes.
private func receive(_ socket: Int32, until marker: String) -> String {
    var received = Data()
    var buffer = [UInt8](repeating: 0, count: 1024)
    while !(String(bytes: received, encoding: .utf8) ?? "").contains(marker) {
        let count = recv(socket, &buffer, buffer.count, 0)
        guard count >= 1 else { break }
        received.append(contentsOf: buffer[0..<count])
    }
    return String(bytes: received, encoding: .utf8) ?? ""
}

/// A raw HTTP GET; returns the connected socket so a test can keep reading.
private func connect(port: UInt16, path: String) throws -> Int32 {
    let client = socket(AF_INET, streamType, 0)
    var address = sockaddr_in()
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = port.bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
    // The listener is bound before the server thread starts, so the first attempt succeeds.
    let connected = withUnsafePointer(to: &address) { pointer in
        pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            socketConnect(client, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    try #require(connected == 0)
    if !path.isEmpty {
        let request = "GET \(path) HTTP/1.1\r\nHost: localhost\r\n\r\n"
        _ = request.withCString { send(client, $0, strlen($0), 0) }
    }
    return client
}

private func socketConnect(_ socket: Int32, _ address: UnsafePointer<sockaddr>, _ length: socklen_t) -> Int32 {
    connect(socket, address, length)
}

// MARK: - Templates

@Suite struct ProjectTemplateTests {
    @Test func catalogListsEveryTemplate() {
        #expect(ProjectTemplate.all.map(\.name) == ["minimal", "landing", "blog", "docs"])
        #expect(ProjectTemplate.named("blog")?.files.count == 4)
        #expect(ProjectTemplate.named("nope") == nil)
        #expect(ProjectTemplate.listing.contains("landing" + String(repeating: " ", count: 2) + "A marketing page"))
        #expect(ProjectTemplate.listing.contains("(default)"))
        #expect(ProjectTemplate.sharedFiles(tailwind: false).map(\.destination).contains("assets/css/style.css"))
        #expect(ProjectTemplate.sharedFiles(tailwind: true).map(\.destination).contains("tailwind.config.ts"))
    }

    @Test(arguments: ["minimal", "landing", "blog", "docs"])
    func everyTemplateScaffolds(name: String) throws {
        let root = try temporaryDirectory("template-\(name)")
        let site = root.appendingPathComponent("Site")
        var command = try New.parse(["Demo", "--template", name, "--path", site.path, "--lang", "pt-BR"])
        try command.run()

        let template = try #require(ProjectTemplate.named(name))
        for file in template.files {
            let path = file.destination.replacingOccurrences(of: "{{PROJECT_NAME}}", with: "Demo")
            #expect(FileManager.default.fileExists(atPath: site.appendingPathComponent(path).path), "missing \(path)")
        }
        for file in FileManager.default.subpaths(atPath: site.path) ?? [] {
            let text = (try? String(contentsOf: site.appendingPathComponent(file), encoding: .utf8)) ?? ""
            #expect(!text.contains("{{"), "\(file) still has a placeholder")
        }
        let agents = try read(site, "AGENTS.md")
        #expect(agents.contains("Sources/Demo/"))
        #expect(try read(site, "Sources/Demo/main.swift").contains("var language = \"pt-BR\""))
    }

    @Test func unknownTemplatesAndMissingNamesAreRejected() throws {
        let root = try temporaryDirectory("template-errors")
        var unknown = try New.parse(["Demo", "--template", "wiki", "--path", root.appendingPathComponent("A").path])
        #expect(throws: ValidationError.self) { try unknown.run() }
        var nameless = try New.parse([])
        #expect(throws: ValidationError.self) { try nameless.run() }
        var listing = try New.parse(["--list-templates"])
        try listing.run()
    }

    @Test func remoteTemplatesAreClonedAndFilled() throws {
        let root = try temporaryDirectory("remote")
        let starter = root.appendingPathComponent("starter")
        try FileManager.default.createDirectory(at: starter.appendingPathComponent("Sources/{{PROJECT_NAME}}"),
                                                withIntermediateDirectories: true)
        try "print(\"{{SITE_TITLE}}\")".write(to: starter.appendingPathComponent("Sources/{{PROJECT_NAME}}/main.swift"),
                                             atomically: true, encoding: .utf8)
        try #"{"message": "Run winged serve"}"#.write(to: starter.appendingPathComponent("winged-template.json"),
                                                     atomically: true, encoding: .utf8)
        try Data([0xFF, 0xFE, 0x00]).write(to: starter.appendingPathComponent("logo.bin"))
        _ = try git(["init", "--quiet"], in: starter)
        _ = try git(["add", "--all"], in: starter)
        _ = try git(["commit", "--quiet", "-m", "starter"], in: starter)

        let site = root.appendingPathComponent("nested/Site")
        let message = try RemoteTemplate.create(from: "file://\(starter.path)", at: site,
                                                placeholders: ["PROJECT_NAME": "Blog", "SITE_TITLE": "My Blog"])
        #expect(message == "Run winged serve")
        #expect(try read(site, "Sources/Blog/main.swift") == "print(\"My Blog\")")
        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent(".git").path))
        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent("winged-template.json").path))
        #expect(FileManager.default.contents(atPath: site.appendingPathComponent("logo.bin").path) == Data([0xFF, 0xFE, 0x00]))

        var withMessage = try New.parse(["Noted", "--template", "file://\(starter.path)",
                                         "--path", root.appendingPathComponent("Noted").path])
        try withMessage.run()

        try FileManager.default.removeItem(at: starter.appendingPathComponent("winged-template.json"))
        _ = try git(["commit", "--quiet", "-am", "no manifest"], in: starter)
        let plain = root.appendingPathComponent("Plain")
        var command = try New.parse(["Plain", "--template", "file://\(starter.path)", "--path", plain.path])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: plain.appendingPathComponent("Sources/Plain/main.swift").path))
    }

    @Test func remoteTemplateErrors() throws {
        let root = try temporaryDirectory("remote-errors")
        #expect(throws: ValidationError.self) {
            try RemoteTemplate.create(from: "git@github.com:x/y.git", at: root.appendingPathComponent("A"), placeholders: [:])
        }
        #expect(throws: ValidationError.self) {
            try RemoteTemplate.create(from: "file://\(root.path)/missing", at: root.appendingPathComponent("B"), placeholders: [:])
        }
        #expect(RemoteTemplate.isRemote("https://github.com/x/y"))
        #expect(!RemoteTemplate.isRemote("blog"))
    }
}

// MARK: - CSS step

@Suite(.serialized) struct CSSStepTests {
    private func project(script: Bool, modules: Bool) throws -> URL {
        let root = try temporaryDirectory("css")
        let scripts = script ? #""build:css": "tailwindcss""# : #""test": "x""#
        try #"{"scripts": {\#(scripts)}}"#.write(to: root.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)
        if modules {
            try FileManager.default.createDirectory(at: root.appendingPathComponent("node_modules"), withIntermediateDirectories: true)
        }
        return root
    }

    /// Puts a fake `npm` first on PATH for the duration of `body`.
    private func withFakeNPM(exitCode: Int, _ body: () throws -> Void) throws {
        let bin = try temporaryDirectory("fake-npm")
        let npm = bin.appendingPathComponent("npm")
        try "#!/bin/sh\nexit \(exitCode)\n".write(to: npm, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: npm.path)
        let original = ProcessInfo.processInfo.environment["PATH"] ?? ""
        setenv("PATH", "\(bin.path):\(original)", 1)
        defer { setenv("PATH", original, 1) }
        try body()
    }

    @Test func detectsTheScript() throws {
        let none = try temporaryDirectory("css-none").path
        #expect(CSSStep.command(in: none) == nil)
        let withoutScript = try project(script: false, modules: true).path
        let withScript = try project(script: true, modules: true).path
        #expect(CSSStep.command(in: withoutScript) == nil)
        #expect(CSSStep.command(in: withScript) == ["npm", "run", "--silent", "build:css"])
    }

    @Test func runsOnlyWhenItCan() throws {
        let withoutScript = try project(script: false, modules: true).path
        let withoutModules = try project(script: true, modules: false).path
        #expect(!CSSStep.run(in: withoutScript))
        #expect(!CSSStep.run(in: withoutModules))
        let ready = try project(script: true, modules: true).path
        try withFakeNPM(exitCode: 0) { #expect(CSSStep.run(in: ready)) }
        try withFakeNPM(exitCode: 1) { #expect(!CSSStep.run(in: ready)) }
    }
}

// MARK: - Live reload and ports

@Suite(.serialized) struct LiveReloadTests {
    @Test func injectsTheScriptBeforeTheBody() {
        let page = Data("<html><body><p>x</p></body></html>".utf8)
        let injected = String(bytes: HTTPServer.injectReloadScript(into: page), encoding: .utf8)
        #expect(injected == "<html><body><p>x</p>\(HTTPServer.reloadScript)</body></html>")
        let fragment = String(bytes: HTTPServer.injectReloadScript(into: Data("<p>x</p>".utf8)), encoding: .utf8)
        #expect(fragment == "<p>x</p>\(HTTPServer.reloadScript)")
        #expect(HTTPServer.injectReloadScript(into: Data([0xFF, 0xFE])) == Data([0xFF, 0xFE]))
    }

    @Test func hubStreamsAReloadEvent() throws {
        var pair: [Int32] = [0, 0]
        try #require(socketpair(AF_UNIX, streamType, 0, &pair) == 0)
        let hub = ReloadHub()
        hub.subscribe(pair[0])
        #expect(hub.count == 1)
        #expect(receive(pair[1], until: ": connected").contains("Content-Type: text/event-stream"))
        #expect(hub.broadcast() == 1)
        #expect(receive(pair[1], until: "data: reload").contains("data: reload"))
        #expect(hub.count < 1)
        #expect(hub.broadcast() == 0)
        close(pair[1])
    }

    @Test func servedPagesReloadWhenTheHubFires() throws {
        let root = try temporaryDirectory("reload-site")
        try "<html><body>home</body></html>".write(to: root.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
        try "body{}".write(to: root.appendingPathComponent("style.css"), atomically: true, encoding: .utf8)
        let hub = ReloadHub()
        let (listener, port) = try HTTPServer.bindFirstAvailable(from: UInt16.random(in: 20_000...50_000))
        let server = HTTPServer(root: root.path, port: port, reloadHub: hub)
        Thread { server.serve(listener: listener) }.start()

        let page = try connect(port: port, path: "/")
        #expect(receive(page, until: "</html>").contains("\(HTTPServer.reloadScript)</body>"))
        close(page)
        let css = try connect(port: port, path: "/style.css")
        #expect(!receive(css, until: "body{}").contains("EventSource"))
        close(css)
        let missing = try connect(port: port, path: "/nope")
        #expect(receive(missing, until: "</script>").contains("404 Not Found"))
        close(missing)

        let silent = try connect(port: port, path: "")
        shutdown(silent, Int32(SHUT_WR))
        close(silent)
        if getuid() != 0 {
            let locked = root.appendingPathComponent("locked.html")
            try "secret".write(to: locked, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: locked.path)
            let unreadable = try connect(port: port, path: "/locked.html")
            #expect(receive(unreadable, until: "\r\n\r\n").contains("500 Internal Server Error"))
            close(unreadable)
        }

        let events = try connect(port: port, path: HTTPServer.reloadPath)
        #expect(receive(events, until: ": connected").contains("text/event-stream"))
        while hub.count < 1 { Thread.sleep(forTimeInterval: 0.01) }
        hub.broadcast()
        #expect(receive(events, until: "data: reload").contains("data: reload"))
        close(events)
    }

    @Test func fallsBackToTheNextFreePort() throws {
        let start = UInt16.random(in: 20_000...50_000)
        let (taken, port) = try HTTPServer.bindFirstAvailable(from: start)
        defer { close(taken) }
        let (next, nextPort) = try HTTPServer.bindFirstAvailable(from: port)
        defer { close(next) }
        #expect(nextPort > port)
        #expect(throws: HTTPServer.ServerError.self) { try HTTPServer.bindFirstAvailable(from: port, attempts: 1) }
    }

    @Test func networkHelpers() {
        if let address = Network.lanAddress() {
            #expect(!address.hasPrefix("127."))
        }
        #expect(Browser.openCommand(for: "http://localhost:8000").last == "http://localhost:8000")
    }
}

// MARK: - winged add

@Suite struct AddCommandTests {
    private func site() throws -> URL {
        let root = try temporaryDirectory("add")
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Sources/Demo"), withIntermediateDirectories: true)
        try "".write(to: root.appendingPathComponent("Sources/Demo/main.swift"), atomically: true, encoding: .utf8)
        return root
    }

    @Test func writesAPageAndAComponent() throws {
        let root = try site()
        var page = try Add.parse(["page", "ContactUsPage", "--path", root.path])
        try page.run()
        let source = try read(root, "Sources/Demo/Pages/ContactUsPage.swift")
        #expect(source.contains("/// Served at /contact-us/"))
        #expect(source.contains("struct ContactUsPage: Page"))
        #expect(source.contains("var title = \"Contact Us\""))

        var component = try Add.parse(["component", "PriceCard", "--path", root.path])
        try component.run()
        #expect(try read(root, "Sources/Demo/Components/PriceCard.swift").contains(".addClass(\"price-card\")"))
    }

    @Test func refusesBadNamesExistingFilesAndAmbiguousTargets() throws {
        let root = try site()
        #expect(throws: ValidationError.self) { try Add.Generator.write(kind: .page, name: "pricing", projectPath: root.path, target: nil) }
        #expect(throws: ValidationError.self) { try Add.Generator.write(kind: .page, name: "Price-List", projectPath: root.path, target: nil) }
        _ = try Add.Generator.write(kind: .page, name: "Pricing", projectPath: root.path, target: nil)
        #expect(throws: ValidationError.self) { try Add.Generator.write(kind: .page, name: "Pricing", projectPath: root.path, target: nil) }

        try FileManager.default.createDirectory(at: root.appendingPathComponent("Sources/Other"), withIntermediateDirectories: true)
        try "".write(to: root.appendingPathComponent("Sources/Other/main.swift"), atomically: true, encoding: .utf8)
        #expect(throws: ValidationError.self) { try Add.Generator.mainTarget(in: root.path) }
        #expect(try Add.Generator.write(kind: .component, name: "Badge", projectPath: root.path, target: "Other")
            == "Sources/Other/Components/Badge.swift")
        #expect(throws: ValidationError.self) { try Add.Generator.mainTarget(in: try temporaryDirectory("add-empty").path) }
    }

    @Test func titlesAndSlugs() {
        #expect(Add.Page.slug("FAQ2024Notes") == "faq2024-notes")
        #expect(Add.Page.title("AboutPage") == "About")
        #expect(Add.Page.title("Page") == "Page")
    }
}

// MARK: - winged deploy

@Suite struct DeployTests {
    private func builtSite() throws -> URL {
        let site = try temporaryDirectory("deploy-site")
        try "<h1>hi</h1>".write(to: site.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
        return site
    }

    private func bareRemote() throws -> URL {
        let remote = try temporaryDirectory("deploy-remote")
        _ = try git(["init", "--quiet", "--bare"], in: remote)
        return remote
    }

    @Test func workflowBuildsAndUploadsTheSite() {
        let plain = GitHubPages.workflow(product: "MySite", tailwind: false)
        #expect(plain.contains("\"$(swift build -c release --show-bin-path)/MySite\" dist"))
        #expect(plain.contains("uses: actions/deploy-pages@v4"))
        #expect(plain.contains("deploy:\n" + String(repeating: " ", count: 4) + "runs-on: macos-15"))
        #expect(!plain.contains("npm"))
        let tailwind = GitHubPages.workflow(product: "MySite", tailwind: true)
        #expect(tailwind.contains("      - uses: actions/setup-node@v4"))
        let step = String(repeating: " ", count: 6) + "- run: "
        #expect(tailwind.contains(step + "npm run build:css\n" + step + "touch dist/.nojekyll"))
    }

    @Test func workflowCommandReadsTheProduct() throws {
        let project = try temporaryDirectory("deploy-command")
        try FileManager.default.createDirectory(at: project.appendingPathComponent("Sources/Demo"), withIntermediateDirectories: true)
        try "print(1)".write(to: project.appendingPathComponent("Sources/Demo/main.swift"), atomically: true, encoding: .utf8)
        try """
        // swift-tools-version: 5.9
        import PackageDescription
        let package = Package(name: "Demo", targets: [.executableTarget(name: "Demo")])
        """.write(to: project.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
        var command = try Deploy.parse(["github-pages", "--workflow", "--path", project.path])
        try command.run()
        #expect(try read(project, GitHubPages.workflowPath).contains("/Demo\" dist"))
    }

    @Test func writesTheWorkflowOnce() throws {
        let project = try temporaryDirectory("deploy-workflow")
        #expect(try GitHubPages.writeWorkflow(projectPath: project.path, product: "Demo") == GitHubPages.workflowPath)
        #expect(try read(project, GitHubPages.workflowPath).contains("Demo\" dist"))
        #expect(throws: ValidationError.self) { try GitHubPages.writeWorkflow(projectPath: project.path, product: "Demo") }
    }

    @Test func pushesTheSiteAsTheOnlyCommitOfTheBranch() throws {
        let site = try builtSite()
        let remote = try bareRemote()
        let commit = try GitHubPages.publish(site: site.path, remote: remote.path, branch: "gh-pages",
                                             cname: "example.com", dryRun: false)
        let files = try git(["--git-dir", remote.path, "ls-tree", "-r", "--name-only", "gh-pages"], in: remote)
        #expect(files.split(separator: "\n").sorted() == [".nojekyll", "CNAME", "index.html"])
        #expect(try git(["--git-dir", remote.path, "rev-parse", "--short", "gh-pages"], in: remote)
            .trimmingCharacters(in: .whitespacesAndNewlines) == commit)
        #expect(!FileManager.default.fileExists(atPath: site.appendingPathComponent(".git").path))
    }

    @Test func dryRunsDoNotPush() throws {
        let site = try builtSite()
        let remote = try bareRemote()
        var command = try Deploy.parse(["github-pages", "--path", site.path, "--output", ".", "--skip-build",
                                        "--remote", remote.path, "--dry-run"])
        try command.run()
        #expect(throws: (any Error).self) {
            try git(["--git-dir", remote.path, "rev-parse", "gh-pages"], in: remote)
        }
        var push = try Deploy.parse(["github-pages", "--path", site.path, "--output", ".", "--skip-build",
                                     "--remote", remote.path])
        try push.run()
        #expect(try git(["--git-dir", remote.path, "ls-tree", "--name-only", "gh-pages"], in: remote).contains("index.html"))
    }

    @Test func refusesAnUnbuiltSite() throws {
        let empty = try temporaryDirectory("deploy-empty")
        #expect(throws: ValidationError.self) {
            try GitHubPages.publish(site: empty.path, remote: "/nowhere", branch: "gh-pages", cname: nil,
                                    dryRun: true)
        }
    }
}
