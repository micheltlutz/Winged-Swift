# Migrating WingedSwift

One section per release, newest first. Every section lists what can break, the mechanical rewrite
for each case, and how to check the result. Sites are regenerated from this library, so the check
that matters is always the same: **the generated `dist/` before and after the upgrade**.

## Upgrading a site — the procedure

1. Snapshot the current output: `winged build && cp -R dist /tmp/dist-before`.
2. Bump the dependency in `Package.swift` (`from: "<new version>"`), then `swift package update`.
3. Read the sections below between your version and the new one, and apply each rewrite.
4. `swift build` — deprecation warnings name what to change next; fix them or leave them for the
   release that removes them.
5. `winged build && diff -r /tmp/dist-before dist`. Every difference must be explained by the
   changelog. A release that says "byte-identical output" must produce an empty diff.

### Let a coding agent do it

The [`wingedswift-migrate` skill](.claude/skills/wingedswift-migrate/SKILL.md) is that procedure
written for an agent. In a site repository, paste this prompt:

```text
Upgrade this site to WingedSwift <version>. Follow
https://github.com/micheltlutz/Winged-Swift/blob/main/.claude/skills/wingedswift-migrate/SKILL.md
step by step: snapshot dist/, bump the dependency, apply every rewrite in MIGRATION.md between
our current version and <version>, rebuild, and show me the dist/ diff before committing.
Stop and ask if the diff contains a change the changelog does not explain.
```

## 2.0 → 2.1

**Additive. Rendered output is byte-identical**, so `diff -r` must come back empty. Two edge cases
can need a one-line fix:

### `StaticSiteGenerator` throws `WingedError`

Every method is now `throws(WingedError)`. Plain `try` and `catch { … }` keep working. A `catch`
that matched a Foundation type no longer matches anything — the compiler warns that the cast always
fails:

```swift
// 2.0
do { try generator.copyAsset(from: "./assets", to: "assets") }
catch let error as CocoaError { print(error.code) }

// 2.1
do { try generator.copyAsset(from: "./assets", to: "assets") }
catch .assetNotFound(let path) { print("missing \(path)") }
catch { print(error) }   // error is WingedError; the Foundation error is in `underlying`
```

`copyAsset` with a missing source now throws `.assetNotFound` *before* creating any directory.

### New names that can collide with yours

2.1 adds `Component`, `TextNode`, `WingedError`, `LinkTarget`, `LinkRelation`, `LoadingStrategy`,
`DecodingHint`, and the `HTMLTag` methods `target(_:)`, `rel(_:)`, `loading(_:)`, `decoding(_:)`,
`hidden(_:)`, `tabIndex(_:)` and `lang(_:)`. A type of yours with one of those names still wins
inside your module. An `extension HTMLTag` of yours that declares one of those methods makes calls
ambiguous — delete yours (the library's replaces the previous value, like `setId`) or rename it.

```bash
grep -rnE "func (target|rel|loading|decoding|hidden|tabIndex|lang)\(|(protocol|struct|class|enum) (Component|TextNode|WingedError|LinkTarget|LinkRelation)\b" Sources
```

### Optional adoption

Nothing below is required; it is what 2.1 makes shorter.

```swift
// Text next to inline elements, no wrapping <span>
P { "Made with "; Strong(content: "WingedSwift") }

// Optional tags and #available
Div { maybeBadge; if #available(macOS 15, *) { NewThing() } }

// Conditional attributes
HTMLTag("input", attributes: {
    Attribute(key: "name", value: "email")
    if isRequired { Attribute.boolean("required") }
})

// Typed attributes instead of strings
A(href: url, content: "Docs").target(.blank).rel([.noopener, .noreferrer])
Img(src: "/hero.png", alt: "Hero").loading(.lazy).decoding(.async)

// A component as a type
struct FeatureCard: Component {
    let title: String
    var body: HTMLTag { Div { H3(content: title) }.addClass("card") }
}
```

Replacing `.setAttribute(key: "target", value: "_blank")` with `.target(.blank)` renders the same
attribute, but **in a different position** if the element already had that attribute — the typed
setters replace instead of appending. Re-run the `dist/` diff after converting.

## 1.x → 2.0

**Nothing was removed.** Every 1.x call site still compiles and produces byte-identical markup —
that is covered by `DeprecatedAPITests`. What changed is the toolchain floor and what the API
*recommends*. The deprecated members are removed in 3.0.

### 1. Toolchain: Swift 6.0+

`Package.swift` moved to `swift-tools-version: 6.0` and language mode 6. You need Xcode 16 /
Swift 6.0 or newer. If your CI pins `macos-13` or the `swift:5.10` container, move to `macos-14`
and `swift:6.0`.

Your own package does **not** have to adopt language mode 6 — a tools-5.9 package can depend on
WingedSwift 2.0 as long as the compiler is 6.0+.

### 2. Rendering options replace the global switch

```swift
// 1.x
HTMLTag.xhtmlSelfClosing = true
let html = page.render(pretty: true)

// 2.0
let html = page.render(RenderOptions(pretty: true, xhtmlSelfClosing: true))
```

| Deprecated | Replacement |
| --- | --- |
| `render(pretty: true)` | `render(.pretty)` |
| `render(pretty: false)` | `render(.compact)` or `render()` |
| `renderCompact()` | `render(.compact)` |
| `renderPretty(indentLevel:)` | `render(.pretty)` — the indent level is internal now |
| `HTMLTag.xhtmlSelfClosing = true` | `RenderOptions(xhtmlSelfClosing: true)` |
| `HTMLTag("div") { Attribute(…) }` | `HTMLTag("div", attributes: { Attribute(…) })` |

`render()` with no arguments still reads the deprecated global, so 1.x code that flips it keeps
working. An explicit `RenderOptions` always wins.

`RenderOptions` also unlocks a custom indent: `RenderOptions(pretty: true, indent: "    ")`.

### 3. Overriding rendering in a subclass

If you subclassed `HTMLTag` and overrode `renderCompact()` or `renderPretty(indentLevel:)`, those
overrides are **no longer called**. The overridable primitive is now a buffered writer:

```swift
public override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
    output += "…"
}
```

This is what made rendering allocate one buffer per page instead of one string per node. `RawHTML`
and `Fragment` in the library are written this way.

### 4. Builder initializers (optional, recommended)

Every container now accepts its children as a trailing closure. The array form is unchanged, so
migrate at your own pace:

```swift
// Still valid
Div(children: [H1(content: "Title"), P(content: "Body")])

// New
Div {
    H1(content: "Title")
    P(content: "Body")
}
```

`if`, `for` and `map` work inside the closure.

**One behavioural note:** `HTMLFragmentBuilder` lost its `buildBlock(_: HTMLTag...)` overload and
its identity `buildExpression(_: [HTMLTag])`, replaced by a generic
`buildExpression<Tag: HTMLTag>(_: [Tag])`. This is what makes
`Ol { ["x", "y"].map { Li(content: $0) } }` compile instead of reporting an ambiguity. Code that
called those static methods directly (very unusual) needs updating; code that just used the builder
does not.

### 5. `Document` replaces hand-assembled pages

```swift
// 1.x
let page = html {
    Head(children: [Title(content: "Home")])
    Body(children: [H1(content: "Hi")])
}
try generator.generate(page: page, to: "index.html")   // the generator added the doctype

// 2.0
let page = Document(lang: "en") {
    Title(content: "Home")
} body: {
    H1(content: "Hi")
}
try generator.generate(document: page, to: "index.html")
```

`html { }` and `generate(page:to:pretty:doctype:)` are not deprecated — use them for fragments and
for pages that are not whole documents.

### 6. Concurrency

`Attribute`, `RenderOptions`, `SitemapURL`, `RSSItem`, `SEO`, `SitemapGenerator`, `HTMLEscape`,
`RSSGenerator` and `StaticSiteGenerator` are `Sendable`. `RSSGenerator` and `StaticSiteGenerator`
are now `final` — if you subclassed either (nothing in the ecosystem does), wrap instead of
inheriting.

`HTMLTag` and `Document` are deliberately **not** `Sendable`: a tag tree is mutable reference state.
Build and render inside one task; pass the resulting `String` across isolation boundaries.

### 7. The `winged` CLI (new)

```bash
swift build -c release            # or install the binary from .build/release/winged
winged new MySite                 # scaffold a project, including its own AGENTS.md
winged build                      # generate into dist/
winged serve --watch              # http://localhost:8000, rebuilding on change
```

`winged new` replaces the `setup.sh` templating in WingedSwift-StarterKit, and `winged serve`
replaces `python3 -m http.server`.

### Checklist

```bash
swift build                     # 1. compiles? deprecation warnings point at what to change
swift test                      # 2. your own suite
grep -rn "xhtmlSelfClosing\|renderCompact()\|renderPretty(\|render(pretty:" Sources
```

Fix what that `grep` finds and you are on the 2.0 API with nothing deprecated left.
