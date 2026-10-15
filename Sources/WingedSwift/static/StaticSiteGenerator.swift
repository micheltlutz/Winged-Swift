import Foundation

/// A generator for creating static HTML files from HTMLTag structures.
///
/// The `StaticSiteGenerator` class provides methods to generate and write HTML files
/// to disk, making it easy to create static websites.
///
/// ## Example
/// ```swift
/// let generator = StaticSiteGenerator(outputDirectory: "./dist")
///
/// let page = html {
///     Head(children: [Title(content: "My Page")])
///     Body(children: [H1(content: "Hello World!")])
/// }
///
/// try generator.generate(page: page, to: "index.html", pretty: true)
/// ```
public final class StaticSiteGenerator: Sendable {
    /// The base output directory where files will be generated.
    public let outputDirectory: String
    
    /// Initializes a new static site generator.
    ///
    /// - Parameter outputDirectory: The directory where files will be written.
    public init(outputDirectory: String) {
        self.outputDirectory = outputDirectory
    }
    
    /// Writes a ``Document`` to disk, doctype and language included.
    ///
    /// - Parameters:
    ///   - document: The document to write.
    ///   - path: The relative path where the file will be saved (e.g. `"index.html"`).
    ///   - options: How to format the markup. Defaults to ``RenderOptions/pretty``.
    /// - Throws: ``WingedError`` if the file cannot be written.
    ///
    /// ## Example
    /// ```swift
    /// try generator.generate(document: homePage, to: "index.html")
    /// ```
    public func generate(document: Document, to path: String, options: RenderOptions = .pretty) throws(WingedError) {
        try writeFile(content: document.render(options), to: path)
    }

    /// Writes several documents in one operation.
    ///
    /// - Parameters:
    ///   - documents: The documents and the paths to write them to.
    ///   - options: How to format the markup. Defaults to ``RenderOptions/pretty``.
    /// - Throws: ``WingedError`` if any file cannot be written.
    ///
    /// ## Example
    /// ```swift
    /// try generator.generateMultiple(documents: [
    ///     (document: home, path: "index.html"),
    ///     (document: about, path: "about/index.html")
    /// ])
    /// ```
    public func generateMultiple(
        documents: [(document: Document, path: String)],
        options: RenderOptions = .pretty
    ) throws(WingedError) {
        for (document, path) in documents {
            try generate(document: document, to: path, options: options)
        }
    }

    /// Generates a single HTML page and writes it to disk.
    ///
    /// - Parameters:
    ///   - page: The HTMLTag representing the page to generate.
    ///   - path: The relative path where the file will be saved (e.g., "index.html" or "blog/post.html").
    ///   - pretty: If true, formats the HTML with indentation. Default is true.
    ///   - doctype: If true, prepends "<!DOCTYPE html>" to the file. Default is true.
    /// - Throws: ``WingedError`` if the file cannot be written.
    public func generate(page: HTMLTag, to path: String, pretty: Bool = true, doctype: Bool = true) throws(WingedError) {
        var html = ""
        if doctype {
            html = "<!DOCTYPE html>\n"
        }
        html += page.render(pretty ? .pretty : .compact)
        try writeFile(content: html, to: path)
    }
    
    /// Generates multiple HTML pages in one operation.
    ///
    /// - Parameters:
    ///   - pages: An array of tuples containing (HTMLTag, path, pretty, doctype).
    ///   - pretty: Default pretty print value for all pages. Default is true.
    ///   - doctype: Default doctype value for all pages. Default is true.
    /// - Throws: ``WingedError`` if any file cannot be written.
    ///
    /// ## Example
    /// ```swift
    /// try generator.generateMultiple([
    ///     (homePage, "index.html"),
    ///     (aboutPage, "about.html"),
    ///     (contactPage, "contact.html")
    /// ])
    /// ```
    public func generateMultiple(
        _ pages: [(page: HTMLTag, path: String)],
        pretty: Bool = true,
        doctype: Bool = true
    ) throws(WingedError) {
        for (page, path) in pages {
            try generate(page: page, to: path, pretty: pretty, doctype: doctype)
        }
    }
    
    /// Copies a file or directory from source to the output directory.
    ///
    /// Useful for copying assets like CSS, JavaScript, or images.
    ///
    /// - Parameters:
    ///   - source: The source file or directory path.
    ///   - destination: The destination path relative to the output directory.
    /// - Throws: ``WingedError/assetNotFound(path:)`` if `source` does not exist, or another
    ///   ``WingedError`` if the copy fails.
    ///
    /// ## Example
    /// ```swift
    /// try generator.copyAsset(from: "./assets/styles.css", to: "css/styles.css")
    /// try generator.copyAsset(from: "./images", to: "images")
    /// ```
    public func copyAsset(from source: String, to destination: String) throws(WingedError) {
        guard FileManager.default.fileExists(atPath: source) else {
            throw .assetNotFound(path: source)
        }
        let destinationPath = "\(outputDirectory)/\(destination)"
        try createDirectory(URL(fileURLWithPath: destinationPath).deletingLastPathComponent())
        try removeIfPresent(destinationPath)
        try fileSystem({ try FileManager.default.copyItem(atPath: source, toPath: destinationPath) }, orThrow: { .copyFailed(source: source, destination: destinationPath, underlying: $0) })
    }
    
    /// Cleans the output directory by removing all files.
    ///
    /// - Parameter createDirectory: If true, recreates the output directory after cleaning. Default is true.
    /// - Throws: ``WingedError`` if the directory cannot be cleaned.
    public func clean(createDirectory: Bool = true) throws(WingedError) {
        try removeIfPresent(outputDirectory)
        if createDirectory {
            try self.createDirectory(URL(fileURLWithPath: outputDirectory))
        }
    }
    
    /// Writes a text file to the output directory.
    ///
    /// Useful for generating files like robots.txt, sitemap.xml, etc.
    ///
    /// - Parameters:
    ///   - content: The content to write.
    ///   - path: The relative path where the file will be saved.
    /// - Throws: ``WingedError`` if the file cannot be written.
    ///
    /// ## Example
    /// ```swift
    /// let sitemap = SitemapGenerator.generate(urls: [...])
    /// try generator.writeFile(content: sitemap, to: "sitemap.xml")
    /// ```
    public func writeFile(content: String, to path: String) throws(WingedError) {
        let fullPath = "\(outputDirectory)/\(path)"
        try createDirectory(URL(fileURLWithPath: fullPath).deletingLastPathComponent())
        try fileSystem({ try content.write(toFile: fullPath, atomically: true, encoding: .utf8) }, orThrow: { .writeFailed(path: fullPath, underlying: $0) })
    }

    private func createDirectory(_ url: URL) throws(WingedError) {
        try fileSystem({ try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }, orThrow: { .directoryCreationFailed(path: url.path, underlying: $0) })
    }

    private func removeIfPresent(_ path: String) throws(WingedError) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        try fileSystem({ try FileManager.default.removeItem(atPath: path) }, orThrow: { .removeFailed(path: path, underlying: $0) })
    }

    /// Runs a Foundation file operation, translating its error into a ``WingedError``.
    private func fileSystem(
        _ operation: () throws -> Void,
        orThrow wrap: (any Error) -> WingedError
    ) throws(WingedError) {
        do {
            try operation()
        } catch {
            throw wrap(error)
        }
    }
}
