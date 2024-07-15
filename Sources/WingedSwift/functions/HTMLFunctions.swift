import Foundation

/// Creates an HTML document using the HTMLBuilder.
public func html(@HTMLBuilder _ content: () -> HTMLTag) -> HTMLTag {
    return content()
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
