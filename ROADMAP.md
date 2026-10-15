# Roadmap

Where the library is going. Work is tracked as
[GitHub milestones](https://github.com/micheltlutz/Winged-Swift/milestones); each issue states the
problem first and carries an API sketch and acceptance criteria. If you want to contribute, pick
one and see `CONTRIBUTING.md`.

Two principles shape every item, and are why some of Ignite's ideas are adapted rather than copied:

- **Zero dependencies in the library.** No Swift macros (they pull in swift-syntax) and no
  third-party Markdown parser. Modern Swift is used through the language itself: result builders,
  protocols with defaults, `@propertyWrapper`, associated types, typed throws — without raising the
  deployment target that sites inherit.
- **CSS-framework agnostic.** Typed modifiers emit plain attributes, inline style or classes — never
  a bundled Bootstrap or Tailwind.

Every change that can break a site or change its rendered HTML ships with a `MIGRATION.md` section
and an entry in the [`wingedswift-migrate` skill](.claude/skills/wingedswift-migrate/SKILL.md).

## Shipped

- **2.0** — result-builder initializers, `RenderOptions`, `Document`, Swift 6 strict concurrency,
  buffered rendering, the `winged` CLI, Swift Testing and golden-file tests.
- **2.1** — bare strings and optional tags in builders, `if #available`, control flow in the
  attributes builder, the `Component` protocol, typed attribute setters, `WingedError` with typed
  throws, and the migration skill. Additive; output byte-identical.
- **2.2** — the `Site` / `Page` / `PageLayout` model with `publish()`, `@Environment` (scoped,
  no global state), generated head meta tags, sitemap, robots.txt, RSS/Atom/JSON feeds and `404.html`.
  Additive; scripts keep rendering byte-identical output.
- **2.3** — `winged new --template` (bundled minimal/landing/blog/docs or a git URL), live reload,
  `serve --open` with port fallback, Tailwind inside `winged build`, `winged add`, and
  `winged deploy github-pages`.
- **2.4** — a dependency-free Markdown renderer, front matter, `Content/` pages with
  `@Environment(\.content)`, tag pages, and feeds from dated content. 2.1–2.4 ship as **2.4.0**.

## [2.1 — Modern Swift builders](https://github.com/micheltlutz/Winged-Swift/milestone/1)

#12 `buildLimitedAvailability` · #13 attributes-builder control flow · #14 strings and optionals in
builders · #15 typed throws / `WingedError` · #16 `Component` · #17 typed attribute modifiers.

## [2.2 — Site model](https://github.com/micheltlutz/Winged-Swift/milestone/2)

A declarative site, inspired by Ignite's `Site` / `StaticPage` and `site.publish()`: describe the
site and its pages as types, and let `publish()` write pages, assets, SEO meta, sitemap and feeds.

#18 `Site` protocol + `publish()` · #19 `Page` protocol · #20 `@Environment`, scoped per render
(no global singleton) · #21 SEO, sitemap and RSS generated on publish · #22 `robots.txt`, Atom and
JSON Feed · #23 `404.html`.

The current script style (`main.swift` + `StaticSiteGenerator`) stays supported.

## [2.3 — CLI: templates & dev loop](https://github.com/micheltlutz/Winged-Swift/milestone/3)

#24 `winged new --template minimal|landing|blog|docs` · #25 `--template <git url>` for third-party
starters · #26 live reload (SSE) · #27 `serve --open`, free-port fallback, LAN URL · #28 Tailwind
step inside `winged build` · #29 `winged add page|component` · #30 `winged deploy` (GitHub Pages
first) · #31 CLI version from a single source.

## [2.4 — Content (Markdown)](https://github.com/micheltlutz/Winged-Swift/milestone/4)

#32 dependency-free Markdown subset · #33 front matter · #34 `Content/` loader and `ArticlePage` ·
#35 tag pages · #36 language classes on code fences for Prism / highlight.js.

## [3.0 — API cleanup](https://github.com/micheltlutz/Winged-Swift/milestone/5)

#37 remove what 2.0 deprecated (`render(pretty:indentLevel:)`, `renderCompact()`,
`renderPretty(indentLevel:)`, `HTMLTag.xhtmlSelfClosing`, the unlabelled `HTMLTag(_:_:)`) ·
#38 RFC: value-type tags · #39 RFC: `javascript:` URL policy · #40 streaming render to a
`FileHandle`.

Before bumping a site to 3.0, clear every WingedSwift deprecation warning on the latest 2.x.

## Not scheduled yet

- **Incremental builds and cache busting**: `StaticSiteGenerator` rewrites every file on every run,
  and there is no asset fingerprinting (`style.a1b2c3.css`). A content hash plus a manifest would
  fix both.
- **Accessibility linting**: a debug-only check for images without `alt`, buttons without a label,
  iframes without a title.
- **`docs/`**: the repository ships a generated DocC site in `docs/` while
  `.github/workflows/docs.yml` publishes to `gh-pages` with `force_orphan: true`. One of the two
  should go.
