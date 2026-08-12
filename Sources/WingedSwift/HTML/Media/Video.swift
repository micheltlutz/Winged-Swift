import Foundation

/// Represents a <video> HTML tag.
///
/// ## Example
/// ```swift
/// Video(src: "/media/demo.mp4", controls: true, poster: "/img/poster.jpg")
/// ```
public class Video: HTMLTag {
    /// Initializes a new <video> tag.
    ///
    /// - Parameters:
    ///   - src: The video URL. Omit it when supplying `Source` children instead.
    ///   - controls: If true, renders the boolean `controls` attribute.
    ///   - autoplay: If true, renders the boolean `autoplay` attribute.
    ///   - loop: If true, renders the boolean `loop` attribute.
    ///   - muted: If true, renders the boolean `muted` attribute.
    ///   - poster: The image shown before playback starts (optional).
    ///   - attributes: Additional attributes of the <video> tag.
    ///   - children: `Source`, `Track` and fallback content.
    public init(
        src: String? = nil,
        controls: Bool = true,
        autoplay: Bool = false,
        loop: Bool = false,
        muted: Bool = false,
        poster: String? = nil,
        attributes: [Attribute] = [],
        children: [HTMLTag] = []
    ) {
        var allAttributes = attributes
        if let src = src {
            allAttributes.append(Attribute(key: "src", value: src))
        }
        if let poster = poster {
            allAttributes.append(Attribute(key: "poster", value: poster))
        }
        if controls { allAttributes.append(.boolean("controls")) }
        if autoplay { allAttributes.append(.boolean("autoplay")) }
        if loop { allAttributes.append(.boolean("loop")) }
        if muted { allAttributes.append(.boolean("muted")) }
        super.init("video", attributes: allAttributes, children: children)
    }

    /// Initializes a new <video> tag, taking its children from a result builder.
    ///
    /// Identical to the array initializer, with the children written as a trailing
    /// closure — `if`, `for` and `map` are all supported inside it.
    ///
    /// ## Example
    /// ```swift
    /// Video {
    ///     P(content: "Hello")
    /// }
    /// ```
    public convenience init(
        src: String? = nil,
        controls: Bool = true,
        autoplay: Bool = false,
        loop: Bool = false,
        muted: Bool = false,
        poster: String? = nil,
        attributes: [Attribute] = [],
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(
            src: src,
            controls: controls,
            autoplay: autoplay,
            loop: loop,
            muted: muted,
            poster: poster,
            attributes: attributes,
            children: children()
        )
    }
}
