import Foundation

/// Creates an HTML document using the HTMLBuilder.
///
/// The builder produces a transparent ``Fragment``; this function is what wraps it in the
/// `<html>` root element, so `if` and `for` blocks nested inside do not each get a root of
/// their own.
public func html(@HTMLBuilder _ content: () -> HTMLTag) -> HTMLTag {
    let root = HTMLTag("html")
    let built = content()
    // Adopt the top-level group's children directly, so the root keeps the flat shape
    // callers expect when they inspect `document.children`.
    if let group = built as? Fragment {
        group.children.forEach { root.addChild($0) }
    } else {
        root.addChild(built)
    }
    return root
}

/// Creates an HTML fragment (no wrapper element) from child tags.
///
/// The children are kept as a tree inside a ``Fragment`` node, so they can be embedded in
/// another tag's `children` without an extra `<div>` while still pretty printing correctly.
public func fragment(@HTMLFragmentBuilder _ content: () -> [HTMLTag]) -> Fragment {
    Fragment(children: content())
}

/// A result builder for constructing HTML tags.
@resultBuilder
public struct HTMLBuilder {
    /// Groups the statements of a block into a transparent ``Fragment``.
    ///
    /// A result builder calls `buildBlock` for every nested block — the body of an `if`, of a
    /// `for` — so it must not introduce an element of its own. `html(_:)` adds the `<html>` root.
    public static func buildBlock(_ components: HTMLTag...) -> HTMLTag {
        return Fragment(children: components)
    }

    /// Returns an empty ``Fragment`` when the optional branch is not taken.
    ///
    /// Returning a bare `HTMLTag("html")` here used to emit a stray `<html></html>` node
    /// in the middle of the document whenever an `if` condition was false.
    public static func buildOptional(_ component: HTMLTag?) -> HTMLTag {
        return component ?? Fragment()
    }

    public static func buildEither(first component: HTMLTag) -> HTMLTag {
        return component
    }

    public static func buildEither(second component: HTMLTag) -> HTMLTag {
        return component
    }

    /// Supports `for` loops inside `html { }` by grouping the iterations in a ``Fragment``.
    public static func buildArray(_ components: [HTMLTag]) -> HTMLTag {
        return Fragment(children: components)
    }

    public static func buildExpression(_ expression: HTMLTag) -> HTMLTag {
        return expression
    }

    public static func buildExpression(_ expression: [HTMLTag]) -> HTMLTag {
        return Fragment(children: expression)
    }
}

/// A result builder for constructing flat lists of HTML tags (fragments, maps of cards, etc.).
///
/// Every statement becomes a `[HTMLTag]` partial result, which is what lets a single tag, an
/// array of tags, a `for` loop and an `if` be mixed freely in the same block. There is exactly one
/// `buildBlock` on purpose: a second overload taking `HTMLTag...` made
/// `Ol { ["x", "y"].map { Li(content: $0) } }` ambiguous.
@resultBuilder
public struct HTMLFragmentBuilder {
    public static func buildBlock(_ components: [HTMLTag]...) -> [HTMLTag] {
        components.flatMap { $0 }
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

    /// Accepts any array of tags, including `[Li]` and other concrete subclasses coming out of a
    /// `map`, which a plain `[HTMLTag]` parameter would reject.
    public static func buildExpression<Tag: HTMLTag>(_ expression: [Tag]) -> [HTMLTag] {
        expression
    }
}

extension HTMLTag {
    /// Creates an element without a dedicated type, taking its children from a result builder.
    ///
    /// This is the escape hatch for elements the library does not model — `<hgroup>`, `<search>`,
    /// a web component — and it behaves exactly like the typed tags.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: The attributes of the HTML tag.
    ///   - content: The content of the HTML tag.
    ///   - escapeContent: If true, escapes HTML special characters in content.
    ///   - children: A builder closure producing the children of the HTML tag.
    ///
    /// ## Example
    /// ```swift
    /// HTMLTag("hgroup") {
    ///     H1(content: "Title")
    ///     P(content: "Subtitle")
    /// }
    /// ```
    public convenience init(
        _ name: String,
        attributes: [Attribute] = [],
        content: String? = nil,
        escapeContent: Bool = true,
        @HTMLFragmentBuilder children: () -> [HTMLTag]
    ) {
        self.init(name, attributes: attributes, children: children(),
                  content: content, escapeContent: escapeContent)
    }

    /// Creates an HTML tag with its attributes from a result builder.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: A closure returning the attributes.
    ///
    /// ## Example
    /// ```swift
    /// HTMLTag("dialog", attributes: {
    ///     Attribute.boolean("open")
    /// })
    /// ```
    public convenience init(_ name: String, @HTMLAttributesBuilder attributes: () -> [Attribute]) {
        self.init(name, attributes: attributes())
    }

    /// Convenience initializer for creating an HTML tag with attributes using a builder.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: A closure returning the attributes.
    ///
    /// - Warning: The unlabelled trailing closure is ambiguous with the children builder.
    ///   Use `HTMLTag(_:attributes:)` instead; this initializer is removed in 3.0.
    @available(*, deprecated, message: "Use HTMLTag(_:attributes:) — the unlabelled form is ambiguous with the children builder.")
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
