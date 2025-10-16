import Foundation

/// Represents a <time> HTML tag.
///
/// The <time> tag defines a specific time (or datetime).
public class Time: HTMLTag {
    /// Initializes a new <time> tag.
    ///
    /// - Parameters:
    ///   - datetime: The machine-readable datetime value.
    ///   - attributes: Additional attributes of the <time> tag.
    ///   - content: The human-readable content of the <time> tag.
    ///   - escapeContent: If true, escapes HTML special characters in content. Default is true for security.
    public init(datetime: String? = nil, attributes: [Attribute] = [], content: String? = nil, escapeContent: Bool = true) {
        var allAttributes = attributes
        if let datetime = datetime {
            allAttributes.append(Attribute(key: "datetime", value: datetime, escape: false))
        }
        super.init("time", attributes: allAttributes, content: content, escapeContent: escapeContent)
    }
}

