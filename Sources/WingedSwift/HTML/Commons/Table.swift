import Foundation

/// Represents a <table> HTML tag.
public class Table: HTMLTag {
    /// Initializes a new <table> tag.
    ///
    /// - Parameters:
    ///   - attributes: The attributes of the <table> tag.
    ///   - children: The children tags of the <table> tag.
    public init(attributes: [Attribute] = [], children: [HTMLTag] = []) {
        super.init("table", attributes: attributes, children: children)
    }
}
