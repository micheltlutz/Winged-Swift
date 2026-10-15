import ArgumentParser
import Foundation

struct Deploy: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Deploy the generated site.",
        discussion: """
        winged deploy github-pages --workflow — writes a GitHub Actions workflow (recommended)
        winged deploy github-pages — builds and force-pushes dist/ to the gh-pages branch
        winged deploy github-pages --dry-run — prepares the commit without pushing
        """
    )

    enum Target: String, ExpressibleByArgument, CaseIterable {
        case githubPages = "github-pages"
    }

    @Argument(help: "Where to deploy: github-pages.")
    var target: Target

    @Option(help: "The project directory.")
    var path: String = "."

    @Option(name: .shortAndLong, help: "The output directory.")
    var output: String = "dist"

    @Flag(help: "Write .github/workflows/deploy-pages.yml instead of pushing.")
    var workflow = false

    @Option(help: "The git remote to push to. Defaults to the project's origin.")
    var remote: String?

    @Option(help: "The branch to push the site to.")
    var branch: String = "gh-pages"

    @Option(help: "A custom domain, written to CNAME.")
    var cname: String?

    @Flag(help: "Deploy the existing output without building first.")
    var skipBuild = false

    @Flag(help: "Prepare the deploy commit, but do not push it.")
    var dryRun = false

    func run() throws {
        if workflow {
            let product = try Build.executableProduct(in: path)
            let file = try GitHubPages.writeWorkflow(projectPath: path, product: product)
            Log.success("Created \(file)")
            Log.detail("In the repository settings, set Pages → Source to \"GitHub Actions\", then push.")
            return
        }

        if !skipBuild { try Build.build(projectPath: path, output: output, release: true) }
        let site = URL(fileURLWithPath: path).appendingPathComponent(output).path
        let destination = try remote ?? Shell.capture(["git", "remote", "get-url", "origin"], in: path)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let commit = try GitHubPages.publish(site: site, remote: destination, branch: branch,
                                             cname: cname, dryRun: dryRun)
        if dryRun {
            Log.success("Prepared \(commit) for \(branch) — not pushed (--dry-run).")
        } else {
            Log.success("Pushed \(commit) to \(branch) on \(destination)")
        }
    }
}

/// GitHub Pages deploys, kept apart from the command so they can be tested.
enum GitHubPages {
    static let workflowPath = ".github/workflows/deploy-pages.yml"

    /// The Actions workflow: build the site on every push to main, upload it as the Pages artifact.
    static func workflow(product: String, tailwind: Bool) -> String {
        let node = tailwind ? """

              - uses: actions/setup-node@v4
                with:
                  node-version: 20
              - run: npm ci || npm install

        """ : "\n"
        let css = tailwind ? "      - run: npm run build:css\n" : ""
        return """
        name: Deploy to GitHub Pages

        on:
          push:
            branches: [main]
          workflow_dispatch:

        permissions:
          contents: read
          pages: write
          id-token: write

        concurrency:
          group: pages
          cancel-in-progress: true

        jobs:
          deploy:
            runs-on: macos-15
            environment:
              name: github-pages
              url: ${{ steps.deployment.outputs.page_url }}
            steps:
              - uses: actions/checkout@v4
        \(node)      - name: Build the site
                run: |
                  swift build -c release
                  "$(swift build -c release --show-bin-path)/\(product)" dist
        \(css)      - run: touch dist/.nojekyll
              - uses: actions/upload-pages-artifact@v3
                with:
                  path: dist
              - id: deployment
                uses: actions/deploy-pages@v4

        """
    }

    /// Writes ``workflowPath``, refusing to overwrite an existing workflow.
    static func writeWorkflow(projectPath: String, product: String) throws -> String {
        let root = URL(fileURLWithPath: projectPath)
        let url = root.appendingPathComponent(workflowPath)
        guard !FileManager.default.fileExists(atPath: url.path) else {
            throw ValidationError("\(workflowPath) already exists.")
        }
        let tailwind = CSSStep.command(in: projectPath) != nil
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try workflow(product: product, tailwind: tailwind).write(to: url, atomically: true, encoding: .utf8)
        return workflowPath
    }

    /// Commits the contents of `site` as the only commit of `branch` and force-pushes it.
    ///
    /// The commit is made in a throwaway repository, so the project's own history and working
    /// tree are never touched.
    /// - Returns: The short hash of the deploy commit.
    static func publish(site: String, remote: String, branch: String, cname: String?,
                        dryRun: Bool) throws -> String {
        guard FileManager.default.fileExists(atPath: site + "/index.html") else {
            throw ValidationError("\(site)/index.html does not exist — build the site first.")
        }
        let work = FileManager.default.temporaryDirectory.appendingPathComponent("winged-deploy-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: work) }
        try FileManager.default.copyItem(atPath: site, toPath: work.path)
        try Data().write(to: work.appendingPathComponent(".nojekyll"))
        if let cname {
            try (cname + "\n").write(to: work.appendingPathComponent("CNAME"), atomically: true, encoding: .utf8)
        }

        // The committer is whoever is configured for the project the site was built in.
        let name = (try? Shell.capture(["git", "config", "user.name"], in: site))?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = (try? Shell.capture(["git", "config", "user.email"], in: site))?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let identity = ["-c", "user.name=\(name.isEmpty ? "winged deploy" : name)",
                        "-c", "user.email=\(email.isEmpty ? "winged@localhost" : email)"]

        _ = try Shell.capture(["git", "init", "--quiet"], in: work.path)
        _ = try Shell.capture(["git", "checkout", "--quiet", "-b", branch], in: work.path)
        _ = try Shell.capture(["git", "add", "--all"], in: work.path)
        let stamp = ISO8601DateFormatter().string(from: Date())
        _ = try Shell.capture(["git"] + identity + ["commit", "--quiet", "-m", "Deploy \(stamp)"], in: work.path)
        let commit = try Shell.capture(["git", "rev-parse", "--short", "HEAD"], in: work.path)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !dryRun {
            _ = try Shell.capture(["git", "push", "--quiet", "--force", remote, "\(branch):\(branch)"], in: work.path)
        }
        return commit
    }
}
