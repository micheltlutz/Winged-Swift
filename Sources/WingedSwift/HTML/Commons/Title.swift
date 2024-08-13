import Foundation

/// Represents a <title> HTML tag.
public class Title: HTMLTag {
    /// Initializes a new title tag.
    ///
    /// - Parameters:
    ///   - content: The content of the <title> tag.
    public init(content: String) {
        super.init("title", attributes: [], children: [], content: content)
    }
}
