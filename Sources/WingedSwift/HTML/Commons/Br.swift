import Foundation

/// Represents a <br> HTML tag (line break).
public class Br: HTMLTag {
    /// Initializes a new <br> tag.
    ///
    /// - Parameter attributes: Additional attributes of the <br> tag.
    public init(attributes: [Attribute] = []) {
        super.init("br", attributes: attributes)
    }
}
