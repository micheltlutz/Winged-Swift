import Foundation

/// A transparent group of HTML nodes that renders its children without a wrapper element.
///
/// Use `Fragment` when you need to return several tags from one expression — a `map` of cards,
/// the body of an `if`, a reusable group of `<meta>` tags — without introducing an extra `<div>`.
/// Unlike ``RawHTML``, a fragment keeps its children as a tree, so pretty printing still indents
/// them correctly.
///
/// ## Example
/// ```swift
/// let items = Fragment(children: names.map { Li(content: $0) })
/// let list = Ul(children: [items])
/// // Result: <ul><li>Ana</li><li>Bruno</li></ul>
/// ```
public class Fragment: HTMLTag {
    /// Initializes a fragment.
    ///
    /// - Parameter children: The nodes to render in sequence.
    public init(children: [HTMLTag] = []) {
        super.init("", attributes: [], children: children, content: nil, escapeContent: false)
    }

    /// Initializes a fragment from a result builder.
    ///
    /// - Parameter children: A builder closure producing the nodes to render in sequence.
    public convenience init(@HTMLFragmentBuilder children: () -> [HTMLTag]) {
        self.init(children: children())
    }

    public override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
        guard options.pretty else {
            for child in children {
                child.write(into: &output, options: options)
            }
            return
        }

        var isFirst = true
        for child in children {
            var rendered = ""
            child.write(into: &rendered, options: options, indentLevel: indentLevel)
            guard !rendered.isEmpty else { continue }
            if !isFirst {
                output += "\n"
            }
            output += rendered
            isFirst = false
        }
    }
}
