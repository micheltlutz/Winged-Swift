import Foundation

/// A reusable piece of markup declared as a type.
///
/// Conforming types describe their markup in `body`, which is an ``HTMLBuilder`` closure. A
/// component can be used anywhere a tag is accepted inside a builder.
///
/// A `static func … -> HTMLTag` remains a perfectly good component; reach for this protocol when
/// the piece has several inputs or you want to read it like a view.
///
/// ## Example
/// ```swift
/// struct FeatureCard: Component {
///     let title: String
///     let text: String
///
///     var body: HTMLTag {
///         Div {
///             H3(content: title)
///             P(content: text)
///         }
///         .addClass("card")
///     }
/// }
///
/// Section {
///     FeatureCard(title: "Fast", text: "Static HTML.")
/// }
/// ```
public protocol Component {
    /// The markup of the component.
    @HTMLBuilder var body: HTMLTag { get }
}

extension Component {
    /// Renders the component's body.
    ///
    /// - Parameter options: How to format the markup.
    /// - Returns: The HTML string.
    public func render(_ options: RenderOptions = .compact) -> String {
        body.render(options)
    }
}
