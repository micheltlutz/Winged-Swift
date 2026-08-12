import Foundation

/// Represents an <audio> HTML tag.
public class Audio: HTMLTag {
    /// Initializes a new <audio> tag.
    ///
    /// - Parameters:
    ///   - src: The audio URL. Omit it when supplying `Source` children instead.
    ///   - controls: If true, renders the boolean `controls` attribute.
    ///   - autoplay: If true, renders the boolean `autoplay` attribute.
    ///   - loop: If true, renders the boolean `loop` attribute.
    ///   - attributes: Additional attributes of the <audio> tag.
    ///   - children: `Source`, `Track` and fallback content.
    public init(
        src: String? = nil,
        controls: Bool = true,
        autoplay: Bool = false,
        loop: Bool = false,
        attributes: [Attribute] = [],
        children: [HTMLTag] = []
    ) {
        var allAttributes = attributes
        if let src = src {
            allAttributes.append(Attribute(key: "src", value: src))
        }
        if controls { allAttributes.append(.boolean("controls")) }
        if autoplay { allAttributes.append(.boolean("autoplay")) }
        if loop { allAttributes.append(.boolean("loop")) }
        super.init("audio", attributes: allAttributes, children: children)
    }

    /// Initializes a new <audio> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Audio {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        src: String? = nil,
        controls: Bool = true,
        autoplay: Bool = false,
        loop: Bool = false,
        attributes: [Attribute] = [],
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            src: src,
            controls: controls,
            autoplay: autoplay,
            loop: loop,
            attributes: attributes,
            children: children()
        )
    }
}
