import Foundation

/// Represents a <wbr> HTML tag.
///
/// The <wbr> tag marks an optional line-break opportunity inside a long word or URL.
/// It is a void element.
public class Wbr: HTMLTag {
    /// Initializes a new <wbr> tag.
    ///
    /// - Parameter attributes: The attributes of the <wbr> tag.
    public init(attributes: [Attribute] = []) {
        super.init("wbr", attributes: attributes)
    }
}
