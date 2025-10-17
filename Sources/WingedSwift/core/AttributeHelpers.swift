import Foundation

/// Extension to HTMLTag providing convenient methods for data attributes and ARIA attributes.
extension HTMLTag {
    /// Adds a data attribute to the HTML tag.
    ///
    /// Data attributes are used to store custom data on HTML elements.
    ///
    /// - Parameters:
    ///   - key: The data attribute name (without the "data-" prefix).
    ///   - value: The value of the data attribute.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let button = Button()
    ///     .dataAttribute(key: "toggle", value: "modal")
    ///     .dataAttribute(key: "target", value: "#myModal")
    /// // Result: <button data-toggle="modal" data-target="#myModal"></button>
    /// ```
    @discardableResult
    public func dataAttribute(key: String, value: String) -> HTMLTag {
        attributes.append(Attribute(key: "data-\(key)", value: value))
        return self
    }
    
    /// Adds multiple data attributes to the HTML tag.
    ///
    /// - Parameter data: A dictionary of data attribute names and values.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .dataAttributes([
    ///         "id": "123",
    ///         "type": "product",
    ///         "price": "99.99"
    ///     ])
    /// // Result: <div data-id="123" data-type="product" data-price="99.99"></div>
    /// ```
    @discardableResult
    public func dataAttributes(_ data: [String: String]) -> HTMLTag {
        for (key, value) in data {
            dataAttribute(key: key, value: value)
        }
        return self
    }
    
    /// Adds an ARIA attribute to the HTML tag.
    ///
    /// ARIA (Accessible Rich Internet Applications) attributes improve accessibility.
    ///
    /// - Parameters:
    ///   - key: The ARIA attribute name (without the "aria-" prefix).
    ///   - value: The value of the ARIA attribute.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let button = Button()
    ///     .ariaAttribute(key: "label", value: "Close")
    ///     .ariaAttribute(key: "expanded", value: "false")
    /// // Result: <button aria-label="Close" aria-expanded="false"></button>
    /// ```
    @discardableResult
    public func ariaAttribute(key: String, value: String) -> HTMLTag {
        attributes.append(Attribute(key: "aria-\(key)", value: value))
        return self
    }
    
    /// Adds multiple ARIA attributes to the HTML tag.
    ///
    /// - Parameter aria: A dictionary of ARIA attribute names and values.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let nav = Nav()
    ///     .ariaAttributes([
    ///         "label": "Main navigation",
    ///         "expanded": "true"
    ///     ])
    /// // Result: <nav aria-label="Main navigation" aria-expanded="true"></nav>
    /// ```
    @discardableResult
    public func ariaAttributes(_ aria: [String: String]) -> HTMLTag {
        for (key, value) in aria {
            ariaAttribute(key: key, value: value)
        }
        return self
    }
    
    /// Sets the role attribute for accessibility.
    ///
    /// - Parameter role: The ARIA role value.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .setRole("navigation")
    /// // Result: <div role="navigation"></div>
    /// ```
    @discardableResult
    public func setRole(_ role: String) -> HTMLTag {
        attributes.removeAll { $0.key == "role" }
        attributes.append(Attribute(key: "role", value: role))
        return self
    }
    
    /// Sets a custom attribute on the HTML tag.
    ///
    /// - Parameters:
    ///   - key: The attribute name.
    ///   - value: The attribute value.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let input = Input(type: "text", name: "email")
    ///     .setAttribute(key: "placeholder", value: "Enter your email")
    ///     .setAttribute(key: "required", value: "true")
    /// ```
    @discardableResult
    public func setAttribute(key: String, value: String) -> HTMLTag {
        attributes.append(Attribute(key: key, value: value))
        return self
    }
}
