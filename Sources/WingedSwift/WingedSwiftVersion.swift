import Foundation

/// The library's version and authorship.
///
/// Until 3.0 this was an enum named `WingedSwift`, which shadowed the module name: writing
/// `WingedSwift.Page` to disambiguate a type found the enum instead. The module name is free now.
public enum WingedSwiftVersion {
    /// The library version, e.g. `"3.0.1"`.
    public static let current = "3.0.1"

    /// The library author.
    public static let author = "Michel Anderson Lutz Teixeira"

    /// The author's website.
    public static let contact = "https://micheltlutz.me"
}
