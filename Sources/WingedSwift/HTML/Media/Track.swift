import Foundation

/// Represents a <track> HTML tag.
///
/// The <track> tag adds a timed text track (captions, subtitles, chapters) to a
/// `Video` or `Audio` parent. It is a void element.
public class Track: HTMLTag {
    /// Initializes a new <track> tag.
    ///
    /// - Parameters:
    ///   - src: The URL of the track file (WebVTT).
    ///   - kind: The kind of track (`subtitles`, `captions`, `descriptions`, `chapters`, `metadata`).
    ///   - srclang: The language of the track text (optional, required for `subtitles`).
    ///   - label: The user-visible title of the track (optional).
    ///   - isDefault: If true, renders the boolean `default` attribute.
    ///   - attributes: Additional attributes of the <track> tag.
    public init(
        src: String,
        kind: String = "subtitles",
        srclang: String? = nil,
        label: String? = nil,
        isDefault: Bool = false,
        attributes: [Attribute] = []
    ) {
        var allAttributes = attributes
        allAttributes.append(Attribute(key: "src", value: src))
        allAttributes.append(Attribute(key: "kind", value: kind))
        if let srclang = srclang {
            allAttributes.append(Attribute(key: "srclang", value: srclang))
        }
        if let label = label {
            allAttributes.append(Attribute(key: "label", value: label))
        }
        if isDefault {
            allAttributes.append(.boolean("default"))
        }
        super.init("track", attributes: allAttributes)
    }
}
