import Foundation

/// Represents an HTML tag.
open class HTMLTag {
    let name: String
    var attributes: [Attribute]
    var children: [HTMLTag]
    var content: String?
    
    private let selfClosingTags: Set<String> = ["img", "br", "hr", "input", "meta", "link", "embed"]
    
    /// Initializes a new HTML tag.
    ///
    /// - Parameters:
    ///   - name: The name of the HTML tag.
    ///   - attributes: The attributes of the HTML tag.
    ///   - children: The children tags of the HTML tag.
    ///   - content: The content of the HTML tag.
    public init(_ name: String, attributes: [Attribute] = [], children: [HTMLTag] = [], content: String? = nil) {
        self.name = name
        self.attributes = attributes
        self.children = children
        self.content = content
    }
    
    /// Adds an attribute to the HTML tag.
    ///
    /// - Parameter attribute: The attribute to add.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func addAttribute(_ attribute: Attribute) -> HTMLTag {
        attributes.append(attribute)
        return self
    }
    
    /// Adds a child tag to the HTML tag.
    ///
    /// - Parameter child: The child HTML tag.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func addChild(_ child: HTMLTag) -> HTMLTag {
        children.append(child)
        return self
    }
    
    /// Sets the content of the HTML tag.
    ///
    /// - Parameter content: The content to be set.
    /// - Returns: The HTMLTag instance.
    @discardableResult
    public func setContent(_ content: String) -> HTMLTag {
        self.content = content
        return self
    }
    
    /// Renders the HTML tag as a string.
    ///
    /// - Returns: The rendered HTML string.
    public func render() -> String {
        var result = "<\(name)"
        
        for attribute in attributes {
            result += " \(attribute.key)=\"\(attribute.value)\""
        }
        
        if selfClosingTags.contains(name) {
            result += " />"
        } else {
            result += ">"
            
            if let content = content {
                result += content
            }
            
            for child in children {
                result += child.render()
            }
            
            result += "</\(name)>"
        }
        
        return result
    }
}
