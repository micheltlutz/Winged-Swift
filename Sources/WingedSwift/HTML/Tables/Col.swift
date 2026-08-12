import Foundation

/// Represents a <col> HTML tag.
///
/// The <col> tag styles one or more columns of a `Table` from inside a `Colgroup`.
/// It is a void element.
public class Col: HTMLTag {
    /// Initializes a new <col> tag.
    ///
    /// - Parameters:
    ///   - span: How many columns the element spans (optional).
    ///   - attributes: Additional attributes of the <col> tag.
    public init(span: Int? = nil, attributes: [Attribute] = []) {
        var allAttributes = attributes
        if let span = span {
            allAttributes.append(Attribute(key: "span", value: String(span), escape: false))
        }
        super.init("col", attributes: allAttributes)
    }
}
