import Foundation

public enum WingedSwift: String {
    case VERSION = "2.0.0"
    case AUTHOR = "Michel Anderson Lutz Teixeira"
    case CONTACT = "https://micheltlutz.me"

    /// The library version, e.g. `"2.0.0"`.
    public static let version = WingedSwift.VERSION.rawValue

    /// The library author.
    public static let author = WingedSwift.AUTHOR.rawValue

    /// The author's website.
    public static let contact = WingedSwift.CONTACT.rawValue
}
