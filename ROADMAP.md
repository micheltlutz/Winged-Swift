# Roadmap

Known gaps and where the library is going. Each item states the problem first — if you want to
contribute, these are the highest-value places to start. See `CONTRIBUTING.md`.

## Shipped in 2.0

Result-builder initializers (`Div { … }`), `RenderOptions` replacing the global `xhtmlSelfClosing`,
the `Document` type, Swift 6 strict concurrency, buffered rendering, the `winged` CLI, the Swift
Testing migration and golden-file tests. See `CHANGELOG.md` and `MIGRATION.md`.

## 2.x — Tooling

### Incremental builds and cache busting

`StaticSiteGenerator` rewrites every file on every run, and there is no asset fingerprinting
(`style.a1b2c3.css`), which forces short cache TTLs on deployed sites. A content hash plus a
manifest would fix both.

### Live reload

`winged serve --watch` rebuilds and asks you to refresh. Injecting a tiny SSE or WebSocket client
into the served HTML would make the page reload itself.

### `winged deploy`

GitHub Pages and Amplify deploys are still per-project shell scripts.

## 3.0 — API cleanup

Remove what 2.0 deprecated: `render(pretty:indentLevel:)`, `renderCompact()`,
`renderPretty(indentLevel:)`, `HTMLTag.xhtmlSelfClosing` and the unlabelled `HTMLTag(_:_:)`
attributes-builder initializer.

Open questions for that release:

- **Value-type tags.** `HTMLTag` is a mutable class, which is why a tree is not `Sendable` and why
  reusing an instance in two places silently shares a node. A struct-based tree would fix both, at
  the cost of a large source break.
- **Typed attributes.** `Attribute(key: "href", value: …)` accepts anything; an enum-backed set for
  the common attributes would catch typos at compile time without closing the door on custom ones.
- **URL attribute policy.** Optionally reject `javascript:` URLs in `A(href:)`, `Img(src:)` and
  `Script(src:)` when the value comes from data.

## Quality

- **Streaming render**: `write(into:)` builds one `String`; writing directly into a `FileHandle`
  would keep memory flat for very large pages.
- **Accessibility linting**: a debug-only check for images without `alt`, buttons without a label,
  iframes without a title — the rules `Iframe` already enforces by construction.
- **`docs/`**: the repository ships a generated DocC site in `docs/` while
  `.github/workflows/docs.yml` publishes to `gh-pages` with `force_orphan: true`. One of the two
  should go.
