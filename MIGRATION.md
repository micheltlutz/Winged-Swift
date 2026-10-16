# Migrating WingedSwift

One section per release, newest first. Every section lists what can break, the mechanical rewrite
for each case, and how to check the result. Sites are regenerated from this library, so the check
that matters is always the same: **the generated `dist/` before and after the upgrade**.

2.1, 2.2, 2.3 and 2.4 ship together as **2.4.0**: coming from 2.0, apply the 2.0 → 2.1,
2.1 → 2.2, 2.2 → 2.3 and 2.3 → 2.4 sections in that order.

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

## 2.4 → 3.0

The first release that removes API. Two changes can alter output; everything else fails at
compile time with a clear message.

**Before bumping:** be on 2.4.x with zero WingedSwift deprecation warnings (`swift build 2>&1 |
grep deprecated`). Every removed member was deprecated in 2.0 and has a direct replacement.

### Removed (compile errors, mechanical fixes)

| Removed | Replacement |
| --- | --- |
| `render(pretty: true)` / `render(pretty: false)` | `render(.pretty)` / `render()` |
| `renderCompact()` | `render()` |
| `renderPretty(indentLevel:)` | `render(.pretty)` |
| `HTMLTag.xhtmlSelfClosing = true` | `render(RenderOptions(xhtmlSelfClosing: true))` |
| `HTMLTag("dialog") { Attribute(…) }` (unlabelled attributes builder) | `HTMLTag("dialog", attributes: { Attribute(…) })` |
| `WingedSwift.version` / `.author` / `.contact` | `WingedSwiftVersion.current` / `.author` / `.contact` |

```bash
grep -rnE "render\(pretty:|renderCompact\(|renderPretty\(|xhtmlSelfClosing *=|WingedSwift\.(version|author|contact|VERSION)" Sources Tests
```

`render()` with no argument still renders compact markup — it is now
`render(_ options: RenderOptions = .compact)`. **Watch for:** 2.x code that flipped
`HTMLTag.xhtmlSelfClosing = true` and then called `render()` got `<br />`; after the rewrite it
must pass `RenderOptions(xhtmlSelfClosing: true)` explicitly or the output changes to `<br>`.

The `enum WingedSwift` was renamed so the module name is usable again: `WingedSwift.Page`,
`WingedSwift.Environment` now disambiguate a clash with your own types.

### Output change 1 — script URLs render as `#`

URL attributes (`href`, `src`, `action`, `formaction`, `poster`, `cite`, `background`,
`xlink:href`, `data`) whose value starts with `javascript:`, `vbscript:` or `data:text/html` —
ignoring case, spaces and control characters — render as `#`. This also covers Markdown links.

```bash
grep -rniE "javascript:|vbscript:|data:text/html" Sources Content
```

For each hit you wrote yourself and want to keep, mark it trusted:

```swift
// 2.x
A(href: "javascript:print()", content: "Print")
// 3.0
A(href: "#", content: "Print").trustedURL("href", "javascript:print()")
```

The `dist/` diff should show only `href="#"` replacements for the hits the grep found.

### Output change 2 — none for byte content, but documents are streamed

`StaticSiteGenerator.generate(document:to:)` now writes through `Document.write(toFile:)`, which
streams `<body>` section by section and replaces the file atomically. The bytes are identical to
`render(_:)`; only memory use and the temporary `.winged-tmp` file during a write differ.

### New in 3.0, optional

`tag.copy()` returns an independent deep copy — use it instead of building a helper function when
you want to reuse a configured tag in several places.

### Subclasses

If you subclassed `HTMLTag` and overrode `render(pretty:)`, `renderCompact()` or
`renderPretty(indentLevel:)`, those overrides no longer compile — override
`write(into:options:indentLevel:)` (see "Overriding rendering in a subclass" below). A subclass
that keeps state of its own should also override `copy()`.

## 2.3 → 2.4

**Sites built with `Document` + `StaticSiteGenerator` render byte-identical output** — `diff -r`
must come back empty.

**A `Site` publishes `Content/`.** If a site on the `Site` model already has a `Content/` folder
with `.md` files (Ignite's convention), those files now become pages, tag pages and feed entries.
That is a new page set in `dist/`, not a change to existing pages. To keep the old output, point
the site elsewhere:

```swift
var contentDirectory = "NoContent"   // any folder that does not exist
```

`site.document(at:)` now `throws` (it reads `Content/`): write `try site.document(at: "/")`.

### New names that can collide with yours

`Markdown`, `MarkdownOptions`, `FrontMatter`, `ContentPage`, `ContentLayout`,
`DefaultContentLayout`, `TagLayout`, `DefaultTagLayout`. As before, your own type wins inside your
module; rename it before adopting the library's.

```bash
grep -rnE "(protocol|struct|class|enum) (Markdown|FrontMatter|ContentPage|ContentLayout|TagLayout)\b" Sources
```

### Optional: Markdown posts

Move post bodies out of Swift strings into `Content/posts/<slug>.md` with front matter, list them
with `@Environment(\.content)`, and drop hand-built `FeedItem`s — dated pages feed the feed. Keep
URLs: a file's path is its location (`Content/posts/hello.md` → `/posts/hello/`) unless it sets
`path:`. Expect `dist/` differences in the post pages' markup (Markdown output) and `<head>`
(`og:type=article`).

## 2.2 → 2.3

**The library API and rendered output are unchanged** — `diff -r` must come back empty. Two CLI
behaviours changed:

- **`winged build` now runs `npm run build:css`** after generating the site when `package.json`
  has that script and `node_modules` exists. If your build script already runs
  `winged build && npm run build:css`, the CSS is simply built twice; drop the second command, or
  pass `--skip-css` to keep your own step. If `node_modules` is missing you get a warning, not a
  failure.
- **`winged serve --watch` injects a live-reload `<script>` into the pages it serves.** The files
  in `dist/` are never modified. If a test of yours scrapes the dev server, use `--no-reload`.

`winged serve` also moves to the next free port when the one requested is taken (it used to fail),
and prints the port it chose.

Optional adoption: `winged add page|component`, `winged deploy github-pages --workflow`, and
`winged new --template` for new projects.

## 2.1 → 2.2

**Additive. Rendered output is byte-identical** for sites built with `Document` and
`StaticSiteGenerator`, so `diff -r` must come back empty. Nothing needs rewriting.

### New names that can collide with yours

2.2 adds `Site`, `Page`, `PageLayout`, `PageBuilder`, `EmptyLayout`, `NotFoundPage`,
`PublishReport`, `Environment`, `EnvironmentValues`, `SiteMetadata`, `PageMetadata`, `FeedItem`,
`FeedFormat`, `FeedGenerator`, `RobotsRule` and `RobotsGenerator`. A type of yours with the same name
still wins inside your module, so existing code keeps compiling. Two things to watch:

- If you want to adopt the new model in a module that already has a `Page` or `Site` type, rename
  yours first. Writing `WingedSwift.Page` does **not** work: the module also exports an
  `enum WingedSwift` (version metadata), and Swift resolves the qualifier to the enum.
- In a file that imports both SwiftUI and WingedSwift, `Environment` is ambiguous. Keep the
  WingedSwift components in files that do not import SwiftUI.

```bash
grep -rnE "(protocol|struct|class|enum|typealias) (Site|Page|PageLayout|Environment|EnvironmentValues|FeedItem|FeedGenerator)\b" Sources
```

If you switch over `WingedError` exhaustively (it appeared in 2.1), add the new
`.duplicatePath` case or a `default:`.

### Optional: moving a script site onto `Site`

This is a rewrite of the site's entry point, not an upgrade step, and it **does change the output**:
the generated `<head>` replaces whatever SEO tags you assembled by hand. Do it in its own commit,
after the upgrade's diff is clean.

```swift
// 2.0 / 2.1 — a script
let home = SiteLayout(title: "RideKeeper", description: "…").page { H1(content: "Hi") }
let generator = StaticSiteGenerator(outputDirectory: "dist")
try generator.clean()
try generator.generate(document: home, to: "index.html")
try generator.copyAsset(from: "assets/css", to: "css")
try generator.writeFile(content: SitemapGenerator.generate(urls: [...]), to: "sitemap.xml")

// 2.2 — a site
struct Home: Page {
    var title = "RideKeeper"
    var body: HTMLTag { H1(content: "Hi") }
}

struct MainLayout: PageLayout {
    func head() -> [HTMLTag] { Link(href: "/css/style.css", rel: "stylesheet") }
    func body(content: HTMLTag) -> [HTMLTag] { Header { … }; MainTag(children: [content]); Footer { … } }
}

struct RideKeeper: Site {
    var name = "RideKeeper"
    var url = "https://ridekeeper.example"
    var description = "…"
    var homePage = Home()
    var layout = MainLayout()
    var pages: [any Page] { About(); Pricing() }
}

try RideKeeper().publish()
```

Mapping, piece by piece:

| Script | Site model |
| --- | --- |
| a `Document` per page | a `struct … : Page` with `title` and `body` |
| your `SiteLayout.page { }` shell | a `PageLayout` — `head()` for stylesheets/scripts, `body(content:)` for the chrome |
| `SEO.complete(…)` / `SEO.common(…)` and `Title(…)` in the head | delete them: `publish()` writes charset, viewport, title, description, canonical, Open Graph and Twitter tags |
| `generate(document:to:)` paths | `Page.path` — the type name by default (`About` → `/about/`); set `path` to keep an existing URL such as `/about.html` |
| `copyAsset(from: "assets/css", to: "css")` | automatic: everything inside `assets/` is copied to the output root |
| hand-written `sitemap.xml` / `robots.txt` | automatic; `isInSitemap = false` hides a page, `robotsRules` changes robots |
| `RSSGenerator` | `feedItems` and `feedFormat` on the site |
| `projectRoot` / `inProject(…)` helpers in `main.swift` | delete them: `publish()` finds the package root itself |

**Keep your URLs.** Before deleting the script, list its output paths
(`cd /tmp/dist-before && find . -name '*.html'`) and make sure every one of them is still produced —
set `path` on the pages whose slug would differ. Then diff: the differences should be confined to
`<head>`, `sitemap.xml`, `robots.txt` and the new `404.html`.

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

**Nothing was removed in 2.0.** Every 1.x call site kept compiling and producing byte-identical
markup. What changed is the toolchain floor and what the API *recommends*. The deprecated members
were removed in 3.0 — see the 2.4 → 3.0 section.

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
