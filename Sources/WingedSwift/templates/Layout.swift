import Foundation

/// Protocol defining a layout template.
///
/// Layouts provide a way to wrap content with consistent structure,
/// such as headers, footers, and navigation.
///
/// ## Example
/// ```swift
/// public class BlogLayout: Layout {
///     let siteTitle: String
///     
///     public init(siteTitle: String) {
///         self.siteTitle = siteTitle
///     }
///     
///     public func render(content: HTMLTag) -> HTMLTag {
///         return html {
///             Head(children: [
///                 Title(content: siteTitle),
///                 Meta(charset: "UTF-8")
///             ])
///             Body(children: [
///                 Header(children: [
///                     H1(content: siteTitle)
///                 ]),
///                 content,
///                 Footer(children: [
///                     P(content: "© 2024")
///                 ])
///             ])
///         }
///     }
/// }
/// ```
public protocol Layout {
    /// Wraps the given content with the layout structure.
    ///
    /// - Parameter content: The content to be wrapped by the layout.
    /// - Returns: The complete HTMLTag with layout applied.
    func render(content: HTMLTag) -> HTMLTag
}

/// Extension providing common layout functionality.
extension Layout {
    /// Wraps multiple content elements in a container before applying layout.
    ///
    /// - Parameter contents: Multiple HTMLTag elements to wrap.
    /// - Returns: The complete HTMLTag with layout applied.
    public func render(contents: [HTMLTag]) -> HTMLTag {
        let container = Div(children: contents)
        return render(content: container)
    }
}
