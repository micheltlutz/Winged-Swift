import Foundation

/// Creates an HTML document using the HTMLBuilder.
public func html(@HTMLBuilder _ content: () -> HTMLTag) -> HTMLTag {
    return content()
}

/// Creates an HTML fragment (no wrapper element) from child tags.
///
/// Children are rendered and concatenated into a single `RawHTML` node,
/// suitable for embedding inside another tag's `children` without an extra `<div>`.
public func fragment(@HTMLFragmentBuilder _ content: () -> [HTMLTag]) -> RawHTML {
    let tags = content()
    return RawHTML(tags.map { $0.render() }.joined())
}

/// A result builder for constructing HTML tags.
@resultBuilder
public struct HTMLBuilder {
    public static func buildBlock(_ components: HTMLTag...) -> HTMLTag {
        let root = HTMLTag("html")
        components.forEach { root.addChild($0) }
        return root
    }

    public static func buildOptional(_ component: HTMLTag?) -> HTMLTag {
        return component ?? HTMLTag("html")
    }

    public static func buildEither(first component: HTMLTag) -> HTMLTag {
        return component
    }

    public static func buildEither(second component: HTMLTag) -> HTMLTag {
        return component
    }
}

/// A result builder for constructing flat lists of HTML tags (fragments, maps of cards, etc.).
@resultBuilder
public struct HTMLFragmentBuilder {
    public static func buildBlock(_ components: HTMLTag...) -> [HTMLTag] {
        Array(components)
    }

    public static func buildBlock(_ components: [HTMLTag]...) -> [HTMLTag] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [HTMLTag]) -> [HTMLTag] {
        components
    }

    public static func buildArray(_ components: [[HTMLTag]]) -> [HTMLTag] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [HTMLTag]?) -> [HTMLTag] {
        component ?? []
    }

    public static func buildEither(first component: [HTMLTag]) -> [HTMLTag] {
        component
    }

    public static func buildEither(second component: [HTMLTag]) -> [HTMLTag] {
        component
    }

    public static func buildExpression(_ expression: HTMLTag) -> [HTMLTag] {
        [expression]
    }

    public static func buildExpression(_ expression: [HTMLTag]) -> [HTMLTag] {
        expression
    }
}

extension HTMLTag {
    /// Convenience initializer for creating an HTML tag with attributes using a builder.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: A closure returning the attributes.
    public convenience init(_ name: String, @HTMLAttributesBuilder _ attributes: () -> [Attribute]) {
        self.init(name, attributes: attributes())
    }
}

/// A result builder for constructing HTML attributes.
@resultBuilder
public struct HTMLAttributesBuilder {
    public static func buildBlock(_ attributes: Attribute...) -> [Attribute] {
        return attributes
    }
}
