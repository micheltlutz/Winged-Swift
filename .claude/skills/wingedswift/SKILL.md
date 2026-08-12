---
name: wingedswift
description: Build HTML pages and static sites with the WingedSwift Swift DSL, or extend the library itself with new tags and helpers. Use when writing Swift code that generates HTML (Document, html { }, HTMLTag, Div/Section/Head/Body, StaticSiteGenerator, SEO/sitemap/RSS helpers), when a project depends on the Winged-Swift package or the `winged` CLI, or when adding an element to the Winged-Swift repository.
---

# WingedSwift

A Swift DSL that builds an HTML **string**. You compose a tree of `HTMLTag` objects and render it.
No browser, no DOM, no runtime — the output is text, usually written to `dist/` by
`StaticSiteGenerator`.

```swift
import WingedSwift

let page = Document(lang: "en") {
    Meta(charset: "UTF-8")
    Title(content: "My Site")
} body: {
    H1(content: "Hello")
    P(content: "Built with Swift")
}

print(page.render())   // <!DOCTYPE html> … , pretty by default
```

## Which workflow are you in?

### A. Using WingedSwift in a site project

1. Confirm the dependency: `Package.swift` should contain
   `.package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "2.0.0")` and the target
   should depend on `.product(name: "WingedSwift", package: "Winged-Swift")`. A new project is one
   command: `winged new MySite`.
2. **Read `references/tag-catalog.md` before writing tags.** It lists every type with both
   initializers — the array form and the builder form. Guessing a type name (`Main`, `Var`,
   `Thead(rows:)`) is the number-one cause of build failures.
3. Write components as `static func … -> HTMLTag` and compose them; see `references/recipes.md`
   for page skeletons, layouts, SEO heads, loops, tables, forms, sitemap and RSS.
4. Skim `references/pitfalls.md` — escaping, void elements, `Fragment` vs `RawHTML` and
   `Document` vs `html { }` behave in ways that are obvious once known and silently wrong otherwise.
5. Build and look at the output: `winged build` then open `dist/index.html`, or
   `winged serve --watch`. Always inspect the generated HTML, not just the exit code.

### B. Extending the Winged-Swift library

Read `AGENTS.md` at the repository root — it is the authority. The contract for a new element is:

1. `Sources/WingedSwift/HTML/<Group>/<Type>.swift`, modeled on `Commons/Div.swift` (plain
   container) or `Commons/A.swift` (required attribute), fully documented.
2. `python3 Scripts/generate-builder-inits.py` to add the trailing-closure initializer.
3. If it is a void element, add its name to `selfClosingTags` in `core/HTMLTag.swift`.
4. A render assertion in `Tests/WingedSwiftTests/TagCatalogTests.swift`.
5. A `CHANGELOG.md` entry.

Then `./Scripts/generate-tag-catalog.sh` and `./Scripts/verify.sh`.

## The rules that prevent most mistakes

1. **Prefer the builder form** — `Div { … }` — with `if`, `for` and `map` inside. The array form
   (`children: [...]`) is equivalent and still supported.
2. **Never invent a type.** Not in the catalog → `HTMLTag("hgroup") { … }` or `RawHTML("<svg …>")`.
3. **Content is escaped by default.** Pass raw text; never pre-escape. `escapeContent: false` only
   for markup you generated (`Script` and `Style` already default to it).
4. **Void elements take no children** — `img`, `br`, `input`, `meta`, `link`, `source`, `col`, …
5. **`Fragment` groups tags; `RawHTML` injects a string.**
6. **Chain the helpers** — `.addClass`, `.setId`, `.dataAttribute`, `.ariaAttribute` return `Self`.
7. **`Document` owns the doctype and `lang`;** `html { }` builds the `<html>` element only.
8. **Rendering is configured per call** with `RenderOptions`, never globally.
9. **Tag trees are not `Sendable`** — render to a `String` before crossing isolation boundaries.

## References

| File | Read it when |
| --- | --- |
| `references/tag-catalog.md` | Before writing any tag — every type and both initializers (generated from source). |
| `references/recipes.md` | Building a page, layout, SEO head, table, form, sitemap or RSS feed. |
| `references/pitfalls.md` | Output looks wrong, or before touching escaping / rendering. |
| `MIGRATION.md` (repo root) | The project is on 1.x and something is deprecated. |
