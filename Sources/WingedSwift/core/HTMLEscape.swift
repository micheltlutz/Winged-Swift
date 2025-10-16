import Foundation

/// Provides HTML escaping functionality to prevent XSS attacks.
public struct HTMLEscape {
    /// Escapes HTML special characters in a string.
    ///
    /// This method converts potentially dangerous characters into their HTML entity equivalents
    /// to prevent XSS (Cross-Site Scripting) attacks.
    ///
    /// - Parameter string: The string to escape.
    /// - Returns: The escaped string with HTML entities.
    ///
    /// ## Example
    /// ```swift
    /// let unsafe = "<script>alert('XSS')</script>"
    /// let safe = HTMLEscape.escape(unsafe)
    /// // Result: "&lt;script&gt;alert(&#x27;XSS&#x27;)&lt;/script&gt;"
    /// ```
    public static func escape(_ string: String) -> String {
        var result = string
        
        // Order matters: & must be escaped first
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&#x27;")
        result = result.replacingOccurrences(of: "/", with: "&#x2F;")
        
        return result
    }
    
    /// Escapes attribute values for use in HTML attributes.
    ///
    /// - Parameter string: The attribute value to escape.
    /// - Returns: The escaped attribute value.
    public static func escapeAttribute(_ string: String) -> String {
        var result = string
        
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&#x27;")
        
        return result
    }
}

