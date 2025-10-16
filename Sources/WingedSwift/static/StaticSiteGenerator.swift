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
public class StaticSiteGenerator {
    /// The base output directory where files will be generated.
    public let outputDirectory: String
    
    /// Initializes a new static site generator.
    ///
    /// - Parameter outputDirectory: The directory where files will be written.
    public init(outputDirectory: String) {
        self.outputDirectory = outputDirectory
    }
    
    /// Generates a single HTML page and writes it to disk.
    ///
    /// - Parameters:
    ///   - page: The HTMLTag representing the page to generate.
    ///   - path: The relative path where the file will be saved (e.g., "index.html" or "blog/post.html").
    ///   - pretty: If true, formats the HTML with indentation. Default is true.
    ///   - doctype: If true, prepends "<!DOCTYPE html>" to the file. Default is true.
    /// - Throws: An error if the file cannot be written.
    public func generate(page: HTMLTag, to path: String, pretty: Bool = true, doctype: Bool = true) throws {
        let fullPath = "\(outputDirectory)/\(path)"
        
        // Create directory if it doesn't exist
        let directoryURL = URL(fileURLWithPath: fullPath).deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // Generate HTML
        var html = ""
        if doctype {
            html = "<!DOCTYPE html>\n"
        }
        html += page.render(pretty: pretty)
        
        // Write to file
        try html.write(toFile: fullPath, atomically: true, encoding: .utf8)
    }
    
    /// Generates multiple HTML pages in one operation.
    ///
    /// - Parameters:
    ///   - pages: An array of tuples containing (HTMLTag, path, pretty, doctype).
    ///   - pretty: Default pretty print value for all pages. Default is true.
    ///   - doctype: Default doctype value for all pages. Default is true.
    /// - Throws: An error if any file cannot be written.
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
    ) throws {
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
    /// - Throws: An error if the copy operation fails.
    ///
    /// ## Example
    /// ```swift
    /// try generator.copyAsset(from: "./assets/styles.css", to: "css/styles.css")
    /// try generator.copyAsset(from: "./images", to: "images")
    /// ```
    public func copyAsset(from source: String, to destination: String) throws {
        let destinationPath = "\(outputDirectory)/\(destination)"
        let destinationURL = URL(fileURLWithPath: destinationPath)
        
        // Create parent directory if needed
        let parentDirectory = destinationURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        
        // Remove existing file/directory if present
        if FileManager.default.fileExists(atPath: destinationPath) {
            try FileManager.default.removeItem(atPath: destinationPath)
        }
        
        // Copy file or directory
        try FileManager.default.copyItem(atPath: source, toPath: destinationPath)
    }
    
    /// Cleans the output directory by removing all files.
    ///
    /// - Parameter createDirectory: If true, recreates the output directory after cleaning. Default is true.
    /// - Throws: An error if the directory cannot be cleaned.
    public func clean(createDirectory: Bool = true) throws {
        let url = URL(fileURLWithPath: outputDirectory)
        
        if FileManager.default.fileExists(atPath: outputDirectory) {
            try FileManager.default.removeItem(at: url)
        }
        
        if createDirectory {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    /// Writes a text file to the output directory.
    ///
    /// Useful for generating files like robots.txt, sitemap.xml, etc.
    ///
    /// - Parameters:
    ///   - content: The content to write.
    ///   - path: The relative path where the file will be saved.
    /// - Throws: An error if the file cannot be written.
    ///
    /// ## Example
    /// ```swift
    /// let sitemap = SitemapGenerator.generate(urls: [...])
    /// try generator.writeFile(content: sitemap, to: "sitemap.xml")
    /// ```
    public func writeFile(content: String, to path: String) throws {
        let fullPath = "\(outputDirectory)/\(path)"
        
        // Create directory if needed
        let directoryURL = URL(fileURLWithPath: fullPath).deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // Write to file
        try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
    }
}

