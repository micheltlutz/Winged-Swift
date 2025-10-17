import Foundation

/// Extension to HTMLTag providing convenient methods for CSS class and ID manipulation.
extension HTMLTag {
    /// Adds a CSS class to the HTML tag.
    ///
    /// If the tag already has a class attribute, the new class is appended to the existing ones.
    ///
    /// - Parameter className: The CSS class name to add.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .addClass("container")
    ///     .addClass("mx-auto")
    /// // Result: <div class="container mx-auto"></div>
    /// ```
    @discardableResult
    public func addClass(_ className: String) -> HTMLTag {
        // Find existing class attribute
        if let classIndex = attributes.firstIndex(where: { $0.key == "class" }) {
            let existingClass = attributes[classIndex].value
            let newValue = "\(existingClass) \(className)"
            attributes[classIndex] = Attribute(key: "class", value: newValue, escape: false)
        } else {
            attributes.append(Attribute(key: "class", value: className, escape: false))
        }
        return self
    }
    
    /// Adds multiple CSS classes to the HTML tag.
    ///
    /// - Parameter classNames: An array of CSS class names to add.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .addClasses(["flex", "items-center", "justify-between"])
    /// // Result: <div class="flex items-center justify-between"></div>
    /// ```
    @discardableResult
    public func addClasses(_ classNames: [String]) -> HTMLTag {
        for className in classNames {
            addClass(className)
        }
        return self
    }
    
    /// Sets the ID attribute of the HTML tag.
    ///
    /// If the tag already has an ID, it will be replaced with the new one.
    ///
    /// - Parameter id: The ID value to set.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .setId("main-content")
    ///     .addClass("container")
    /// // Result: <div id="main-content" class="container"></div>
    /// ```
    @discardableResult
    public func setId(_ id: String) -> HTMLTag {
        // Remove existing id if present
        attributes.removeAll { $0.key == "id" }
        attributes.append(Attribute(key: "id", value: id, escape: false))
        return self
    }
    
    /// Sets inline CSS styles for the HTML tag.
    ///
    /// - Parameter style: The CSS style string.
    /// - Returns: The HTMLTag instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// let div = Div()
    ///     .setStyle("color: red; margin: 10px;")
    /// // Result: <div style="color: red; margin: 10px;"></div>
    /// ```
    @discardableResult
    public func setStyle(_ style: String) -> HTMLTag {
        // Remove existing style if present
        attributes.removeAll { $0.key == "style" }
        attributes.append(Attribute(key: "style", value: style, escape: false))
        return self
    }
}
