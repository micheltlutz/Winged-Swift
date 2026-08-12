# AGENTS.md — working with WingedSwift

Instructions for coding agents (Claude Code, Cursor, Codex, …) working **on** this repository or
**with** this library in a site project. Humans are welcome to read it too — it is the shortest
accurate description of how the library works.

## What WingedSwift is

A dependency-free Swift DSL that builds an **HTML string**. You compose a tree of `HTMLTag` objects
and render it. That is the whole model:

- There is no browser, no DOM, no reactivity, no runtime. Output is text.
- `HTMLTag` is a **class** (reference semantics, Composite pattern). Every element type subclasses it.
- Every element type is a thin wrapper: it fixes the tag name and exposes the attributes that
  element actually needs.
- The typical consumer is a small SwiftPM executable that renders pages and writes them to `dist/`
  with `StaticSiteGenerator` — scaffolded by `winged new`.

```swift
import WingedSwift

let page = Document(lang: "en") {
    Meta(charset: "UTF-8")
    Title(content: "My Site")
} body: {
    H1(content: "Hello, WingedSwift!")
    P(content: "Creating HTML with Swift is awesome!")
}

print(page.render())
// <!DOCTYPE html>
// <html lang="en">
//   <head>
//     <meta charset="UTF-8">
//     <title>My Site</title>
//   </head>
//   …
```

## Commands

Run these from the repository root.

| Command | What it does |
| --- | --- |
| `swift build` | Compiles the library and the `winged` CLI. |
| `swift test` | Runs the Swift Testing suite (`Tests/WingedSwiftTests/`). |
| `swift test --filter BuilderInitTests` | Runs one suite. |
| `WINGED_UPDATE_FIXTURES=1 swift test` | Regenerates the golden HTML fixtures after an intentional output change. |
| `swiftlint lint --strict` | Lints; config in `.swiftlint.yml`. |
| `./Scripts/generate-tag-catalog.sh` | Regenerates the tag catalog from the sources. |
| `./Scripts/generate-builder-inits.py` | Adds the builder initializer to any tag missing one. |
| `./Scripts/verify.sh` | **Build + test + lint + catalog + CLI + a real page render.** |

**Run `./Scripts/verify.sh` before you report that a change is done.** It is the single check that
covers everything CI does.

## Repository map

```
Sources/
├── WingedSwift/
│   ├── core/          HTMLTag, RenderOptions, Document, Attribute, HTMLEscape, Fragment, RawHTML, helpers
│   ├── functions/     html { }, fragment { }, the result builders
│   ├── HTML/
│   │   ├── Commons/   structural + text elements (Div, Section, H1…H6, Details, …)
│   │   ├── Forms/     Form, Input, Select, Legend, Progress, …
│   │   ├── Tables/    Table parts (Thead, Tbody, Caption, Col, …)
│   │   ├── Media/     Video, Audio, Source, Track, Iframe
│   │   └── Code/      Pre, Code, Embed
│   ├── seo/           SEO meta helpers, SitemapGenerator
│   ├── feed/          RSSGenerator
│   ├── static/        StaticSiteGenerator (writes files, copies assets)
│   └── templates/     Layout protocol
└── WingedCLI/         the `winged` command: new / build / serve
```

Full API surface: [`.claude/skills/wingedswift/references/tag-catalog.md`](.claude/skills/wingedswift/references/tag-catalog.md)
(generated — never edit by hand).
Common mistakes: [`.claude/skills/wingedswift/references/pitfalls.md`](.claude/skills/wingedswift/references/pitfalls.md).
Copy-pasteable snippets: [`.claude/skills/wingedswift/references/recipes.md`](.claude/skills/wingedswift/references/recipes.md).
Upgrading from 1.x: [`MIGRATION.md`](MIGRATION.md).

## Rules

**1. Prefer the builder form.** Every container takes its children as a trailing closure. `if`, `for`
and `map` all work inside it. The array form (`children: [...]`) is equivalent and still supported —
use it when you already have an array in hand.

```swift
Section {
    H2(content: "Features")
    Ul {
        for feature in features {
            Li(content: feature.title)
        }
    }
}
.addClass("features")
```

**2. Never invent a type name.** If an element has no dedicated type in the catalog, use the base
class or raw markup — both are first-class, not workarounds:

```swift
HTMLTag("hgroup") { H1(content: "Title"); P(content: "Subtitle") }
RawHTML("<svg viewBox=\"0 0 24 24\"><path d=\"M4 4h16\"/></svg>")
```

Watch the names that differ from the HTML element because the word is a Swift keyword:
`MainTag` → `<main>`, `VarTag` → `<var>`.

**3. Content is escaped, attributes are escaped.** `P(content: "<b>hi</b>")` renders
`&lt;b&gt;hi&lt;/b&gt;`. That is the correct default. Opt out only for markup you produced
yourself: `P(content: someHTML, escapeContent: false)`. `Script` and `Style` already default to
`escapeContent: false`, because escaping would corrupt JS and CSS.

**4. Never pre-escape.** Pass raw text and let the library escape it once. Passing `"&amp;"` gets
you `&amp;amp;`.

**5. Void elements take no children.** `img`, `br`, `hr`, `input`, `meta`, `link`, `embed`, `area`,
`base`, `col`, `source`, `track`, `wbr` render as `<img …>` with no closing tag. `HTMLTag` knows
this list; if you add a void element, add it there too (see below).

**6. `Fragment` groups, `RawHTML` injects.** Use `fragment { }` / `Fragment(children:)` to return
several tags without an extra `<div>` — it keeps the tree, so pretty printing still works. Use
`RawHTML` only for a markup **string** you already have.

**7. Style with the chainable helpers, not hand-built attributes.** They return `Self`, so the
concrete type survives the chain:

```swift
let card: Div = Div { … }
    .addClasses(["rounded-lg", "p-6", "bg-gray-800"])
    .setId("pricing")
    .dataAttribute(key: "analytics", value: "pricing-card")
    .ariaAttribute(key: "label", value: "Pricing")
```

`addClass` appends, `setId` / `setStyle` / `setRole` replace.

**8. Boolean attributes use `Attribute.boolean`.** `Attribute.boolean("required")` renders
` required`, not ` required="true"`.

**9. `Document` owns the doctype and the language; `html { }` does not.** `html { }` produces the
`<html>` element only — reach for `Document` unless you are rendering a fragment of a page.

**10. Rendering is configured by value, never globally.** `render(.compact)` (default),
`render(.pretty)`, or a custom `RenderOptions(pretty:indent:xhtmlSelfClosing:)`. `<pre>`, `<code>`
and `<textarea>` are always compact, because indentation inside them is visible text.

**11. Tag trees are not `Sendable`.** `HTMLTag` is a mutable class. Build and render a page inside
one task, then pass the resulting `String` across isolation boundaries. `Attribute`,
`RenderOptions`, `SitemapURL`, `RSSItem`, `StaticSiteGenerator` and `RSSGenerator` are `Sendable`.

## Recipes

### A full page written to disk

```swift
import WingedSwift

let page = Document(lang: "en") {
    Fragment(children: SEO.complete(
        title: "RideKeeper",
        description: "Motorcycle maintenance companion",
        image: "https://ridekeeper.example/og.jpg",
        url: "https://ridekeeper.example"
    ))
    Title(content: "RideKeeper")
    Link(href: "/css/style.css", rel: "stylesheet")
} body: {
    Header { Nav { A(href: "/", content: "Home") } }
    MainTag { H1(content: "Track every service") }
    Footer { P(content: "© 2026") }
}

let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()
try generator.generate(document: page, to: "index.html")
try generator.copyAsset(from: "./assets/css", to: "css")
try generator.writeFile(content: SitemapGenerator.generate(urls: [
    SitemapURL(loc: "https://ridekeeper.example/", changefreq: "weekly", priority: 1.0)
]), to: "sitemap.xml")
```

### A reusable component

Return `HTMLTag` from a `static func` — this is the idiomatic pattern in projects using the library:

```swift
enum Components {
    static func featureCard(title: String, body: String) -> HTMLTag {
        Div {
            H3(content: title).addClass("text-xl font-bold")
            P(content: body).addClass("text-gray-300")
        }
        .addClass("p-6 bg-gray-800 rounded-lg")
    }
}
```

More in [`references/recipes.md`](.claude/skills/wingedswift/references/recipes.md).

## Adding an element to the library

Five steps — a change that skips any of them will fail `./Scripts/verify.sh`:

1. **The file.** `Sources/WingedSwift/HTML/<Group>/<Type>.swift`, one type per file. Copy the shape
   of `HTML/Commons/Div.swift` (plain container) or `HTML/Commons/A.swift` (required attribute).
   Document the class and every initializer parameter — the public API is 100 % documented and DocC
   is published from it.
2. **The builder initializer.** Run `python3 Scripts/generate-builder-inits.py`; it writes the
   convenience initializer from the designated one *and* regenerates
   `Tests/WingedSwiftTests/BuilderInitCoverageTests.swift`, which calls every builder initializer
   once. Skip this for void elements.
3. **Void elements.** If the element has no closing tag, add its name to `selfClosingTags` in
   `Sources/WingedSwift/core/HTMLTag.swift`.
4. **A test.** Add a render assertion to `Tests/WingedSwiftTests/TagCatalogTests.swift`.
5. **`CHANGELOG.md`.** Add it under the current `### Added` section (Keep a Changelog format).

Then run `./Scripts/generate-tag-catalog.sh` so the catalog picks the new element up.

## Conventions

- 4-space indent, no trailing whitespace, one trailing newline. `swiftlint lint --strict` is the
  arbiter; `.swiftlint.yml` deliberately allows one-letter type names (`A`, `P`, `H1`).
- Every `public` declaration carries a doc comment with `- Parameters:` and, where it helps, an
  `## Example` block.
- Comments explain *why*, not *what*. The existing code has very few of them; match that.
- Tests are Swift Testing (`@Suite`, `@Test`, `#expect`). Assert on rendered strings, not on
  internal tree shape. `DeprecatedAPITests` is the one XCTest file left, on purpose — see its
  header comment.
- Deprecations carry `@available(*, deprecated, message:)` and stay for one major version.
- Commit messages follow the CHANGELOG vocabulary: `Add:`, `Fix:`, `Change:`.
- Branch from `develop`, open the PR against `develop`. See `CONTRIBUTING.md`.

## Before you say you are done

```bash
./Scripts/verify.sh
```

If you changed rendering behaviour, say so explicitly in your summary, update the golden fixtures
(`WINGED_UPDATE_FIXTURES=1 swift test`) and add the entry to `CHANGELOG.md` — downstream sites are
regenerated from this library and a whitespace or escaping change shows up in every page.
