import Foundation

/// Represents an <hr> HTML tag (thematic break / horizontal rule).
public class Hr: HTMLTag {
    /// Initializes a new <hr> tag.
    ///
    /// - Parameter attributes: Additional attributes of the <hr> tag.
    public init(attributes: [Attribute] = []) {
        super.init("hr", attributes: attributes)
    }
}
