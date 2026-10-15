import Foundation

/// The CSS build a project declares in `package.json` — the Tailwind scaffold's `build:css`.
///
/// `winged build` runs it after generating the site, because Tailwind scans the generated HTML
/// for the classes it has to emit.
enum CSSStep {
    static let scriptName = "build:css"

    /// The command to run, or `nil` when the project has no `build:css` script.
    static func command(in projectPath: String) -> [String]? {
        let manifest = URL(fileURLWithPath: projectPath).appendingPathComponent("package.json")
        guard let data = FileManager.default.contents(atPath: manifest.path),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scripts = object["scripts"] as? [String: Any],
              scripts[scriptName] != nil else {
            return nil
        }
        return ["npm", "run", "--silent", scriptName]
    }

    /// Runs the CSS build if there is one. A missing `npm` or `node_modules` is a warning, not a
    /// failure: the HTML is already written.
    /// - Returns: Whether the CSS was built.
    @discardableResult
    static func run(in projectPath: String) -> Bool {
        guard let command = command(in: projectPath) else { return false }
        let modules = URL(fileURLWithPath: projectPath).appendingPathComponent("node_modules").path
        guard FileManager.default.fileExists(atPath: modules) else {
            Log.warning("package.json has a \(scriptName) script but node_modules is missing — run `npm install`.")
            return false
        }
        do {
            try Shell.run(command, in: projectPath)
            Log.success("CSS built (npm run \(scriptName))")
            return true
        } catch {
            Log.warning("The CSS build failed: \(error)")
            return false
        }
    }
}
