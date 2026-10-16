import Foundation

/// Where a link or form opens, for the `target` attribute.
public enum LinkTarget: String, Sendable, CaseIterable {
    /// A new tab or window (`_blank`).
    case blank = "_blank"
    /// The current browsing context (`_self`).
    case current = "_self"
    /// The parent browsing context (`_parent`).
    case parent = "_parent"
    /// The top-level browsing context (`_top`).
    case top = "_top"
}

/// A link relation, for the `rel` attribute.
///
/// Use ``custom(_:)`` for any relation not listed here.
public enum LinkRelation: Sendable, Hashable {
    case alternate, author, bookmark, canonical, external, help, icon, license, manifest, me
    case next, nofollow, noopener, noreferrer, preconnect, prefetch, preload, prev, search
    case stylesheet, tag
    /// Any other relation, written as given.
    case custom(String)

    /// The keyword as it appears in the attribute.
    public var keyword: String {
        switch self {
        case .alternate: return "alternate"
        case .author: return "author"
        case .bookmark: return "bookmark"
        case .canonical: return "canonical"
        case .external: return "external"
        case .help: return "help"
        case .icon: return "icon"
        case .license: return "license"
        case .manifest: return "manifest"
        case .me: return "me"
        case .next: return "next"
        case .nofollow: return "nofollow"
        case .noopener: return "noopener"
        case .noreferrer: return "noreferrer"
        case .preconnect: return "preconnect"
        case .prefetch: return "prefetch"
        case .preload: return "preload"
        case .prev: return "prev"
        case .search: return "search"
        case .stylesheet: return "stylesheet"
        case .tag: return "tag"
        case .custom(let value): return value
        }
    }
}

/// When a resource loads, for the `loading` attribute of `<img>` and `<iframe>`.
public enum LoadingStrategy: String, Sendable, CaseIterable {
    case lazy, eager
}

/// How an image is decoded, for the `decoding` attribute.
public enum DecodingHint: String, Sendable, CaseIterable {
    case sync, async, auto
}

/// Typed, chainable setters for common global and link attributes.
///
/// Each one replaces any previous value of the same attribute, like ``HTMLTag/setId(_:)``.
extension HTMLTag {
    /// Sets the `target` attribute.
    ///
    /// - Parameter target: Where the link opens.
    /// - Returns: The tag, for chaining.
    ///
    /// ## Example
    /// ```swift
    /// A(href: "https://swift.org", content: "Swift")
    ///     .target(.blank)
    ///     .rel([.noopener, .noreferrer])
    /// // <a href="https://swift.org" target="_blank" rel="noopener noreferrer">Swift</a>
    /// ```
    @discardableResult
    public func target(_ target: LinkTarget) -> Self {
        replaceAttribute(Attribute(key: "target", value: target.rawValue))
    }

    /// Sets the `rel` attribute.
    ///
    /// - Parameter relations: The relations, written space-separated in order.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func rel(_ relations: [LinkRelation]) -> Self {
        replaceAttribute(Attribute(key: "rel", value: relations.map(\.keyword).joined(separator: " ")))
    }

    /// Sets the `loading` attribute.
    ///
    /// - Parameter strategy: When the resource loads.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func loading(_ strategy: LoadingStrategy) -> Self {
        replaceAttribute(Attribute(key: "loading", value: strategy.rawValue))
    }

    /// Sets the `decoding` attribute.
    ///
    /// - Parameter hint: How the image is decoded.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func decoding(_ hint: DecodingHint) -> Self {
        replaceAttribute(Attribute(key: "decoding", value: hint.rawValue))
    }

    /// Adds or removes the boolean `hidden` attribute.
    ///
    /// - Parameter isHidden: If true (the default), the element is hidden.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func hidden(_ isHidden: Bool = true) -> Self {
        attributes.removeAll { $0.key == "hidden" }
        if isHidden {
            attributes.append(.boolean("hidden"))
        }
        return self
    }

    /// Sets the `tabindex` attribute.
    ///
    /// - Parameter index: The tab order; `-1` removes the element from sequential navigation.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func tabIndex(_ index: Int) -> Self {
        replaceAttribute(Attribute(key: "tabindex", value: String(index)))
    }

    /// Sets the `lang` attribute.
    ///
    /// - Parameter code: A BCP 47 language tag, such as `"pt-BR"`.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func lang(_ code: String) -> Self {
        replaceAttribute(Attribute(key: "lang", value: code))
    }

    /// Sets a URL attribute that is rendered as given, even if it is a `javascript:` URL.
    ///
    /// Script URLs in `href`, `src`, `action` and the other URL attributes render as `#` unless
    /// they are set this way. Use it only for values you wrote yourself.
    ///
    /// - Parameters:
    ///   - key: The attribute name, such as `"href"`.
    ///   - value: The URL.
    /// - Returns: The tag, for chaining.
    @discardableResult
    public func trustedURL(_ key: String, _ value: String) -> Self {
        replaceAttribute(.trustedURL(key: key, value: value))
    }

    private func replaceAttribute(_ attribute: Attribute) -> Self {
        attributes.removeAll { $0.key == attribute.key }
        attributes.append(attribute)
        return self
    }
}
