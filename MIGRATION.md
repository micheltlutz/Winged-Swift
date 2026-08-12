# Migrating from 1.x to 2.0

**Nothing was removed.** Every 1.x call site still compiles and produces byte-identical markup —
that is covered by `DeprecatedAPITests`. What changed is the toolchain floor and what the API
*recommends*. The deprecated members are removed in 3.0.

## 1. Toolchain: Swift 6.0+

`Package.swift` moved to `swift-tools-version: 6.0` and language mode 6. You need Xcode 16 /
Swift 6.0 or newer. If your CI pins `macos-13` or the `swift:5.10` container, move to `macos-14`
and `swift:6.0`.

Your own package does **not** have to adopt language mode 6 — a tools-5.9 package can depend on
WingedSwift 2.0 as long as the compiler is 6.0+.

## 2. Rendering options replace the global switch

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

## 3. Overriding rendering in a subclass

If you subclassed `HTMLTag` and overrode `renderCompact()` or `renderPretty(indentLevel:)`, those
overrides are **no longer called**. The overridable primitive is now a buffered writer:

```swift
public override func write(into output: inout String, options: RenderOptions, indentLevel: Int = 0) {
    output += "…"
}
```

This is what made rendering allocate one buffer per page instead of one string per node. `RawHTML`
and `Fragment` in the library are written this way.

## 4. Builder initializers (optional, recommended)

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

## 5. `Document` replaces hand-assembled pages

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

## 6. Concurrency

`Attribute`, `RenderOptions`, `SitemapURL`, `RSSItem`, `SEO`, `SitemapGenerator`, `HTMLEscape`,
`RSSGenerator` and `StaticSiteGenerator` are `Sendable`. `RSSGenerator` and `StaticSiteGenerator`
are now `final` — if you subclassed either (nothing in the ecosystem does), wrap instead of
inheriting.

`HTMLTag` and `Document` are deliberately **not** `Sendable`: a tag tree is mutable reference state.
Build and render inside one task; pass the resulting `String` across isolation boundaries.

## 7. The `winged` CLI (new)

```bash
swift build -c release            # or install the binary from .build/release/winged
winged new MySite                 # scaffold a project, including its own AGENTS.md
winged build                      # generate into dist/
winged serve --watch              # http://localhost:8000, rebuilding on change
```

`winged new` replaces the `setup.sh` templating in WingedSwift-StarterKit, and `winged serve`
replaces `python3 -m http.server`.

## Checklist

```bash
swift build                     # 1. compiles? deprecation warnings point at what to change
swift test                      # 2. your own suite
grep -rn "xhtmlSelfClosing\|renderCompact()\|renderPretty(\|render(pretty:" Sources
```

Fix what that `grep` finds and you are on the 2.0 API with nothing deprecated left.
