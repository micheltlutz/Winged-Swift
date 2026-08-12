import Foundation

/// Represents a <meter> HTML tag.
///
/// The <meter> tag shows a scalar measurement within a known range (disk usage, a score).
/// Use `Progress` for task completion instead.
public class Meter: HTMLTag {
    /// Initializes a new <meter> tag.
    ///
    /// - Parameters:
    ///   - value: The current numeric value.
    ///   - min: The lower bound of the range. Defaults to `0.0`.
    ///   - max: The upper bound of the range. Defaults to `1.0`.
    ///   - attributes: Additional attributes of the <meter> tag.
    ///   - content: The fallback content of the <meter> tag.
    public init(
        value: Double,
        min: Double = 0.0,
        max: Double = 1.0,
        attributes: [Attribute] = [],
        content: String? = nil
    ) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "value", value: String(value), escape: false))
        allAttributes.append(Attribute(key: "min", value: String(min), escape: false))
        allAttributes.append(Attribute(key: "max", value: String(max), escape: false))
        super.init("meter", attributes: allAttributes, content: content)
    }
}
