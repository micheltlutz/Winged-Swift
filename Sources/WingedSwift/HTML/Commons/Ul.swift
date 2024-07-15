import Foundation

/// Represents a <ul> HTML tag.
public class Ul: HTMLTag {
    /// Initializes a new <ul> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <ul> tag.
    ///   - children: The children tags of the <ul> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("ul", attributes: attributes, children: children)
    }
}
