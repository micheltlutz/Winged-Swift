---
name: wingedswift-migrate
description: Upgrade a site or package that depends on WingedSwift to a newer version (e.g. 2.0 → 2.1, 2.x → 3.0) safely. Use when asked to bump, update or upgrade Winged-Swift / WingedSwift / the winged CLI in a project, when a build breaks after `swift package update` pulled a new WingedSwift, or when deprecation warnings from WingedSwift need fixing.
---

# Upgrading a project to a new WingedSwift version

The site's HTML is regenerated from the library, so an upgrade can change every page at once. The
procedure below makes every change visible before it is committed. Do not skip the snapshot or the
diff — they are the whole point.

The source of truth for what changed is `MIGRATION.md` and `CHANGELOG.md` in the Winged-Swift
repository: https://github.com/micheltlutz/Winged-Swift/blob/main/MIGRATION.md. Read the sections
between the project's current version and the target version. Do not rely on memory of the API.

## 1. Establish where you are

```bash
git status                     # must be clean; commit or stash first
grep -n "Winged-Swift" Package.swift
grep -A3 '"winged-swift"' Package.resolved | grep version
swift --version                # 2.x needs Swift 6.0+
```

Write down the current version (from `Package.resolved`) and the target version.

## 2. Snapshot the current output

Build with the **current** version and keep the result:

```bash
winged build                   # or: swift run <ExecutableName> dist
rm -rf /tmp/winged-dist-before && cp -R dist /tmp/winged-dist-before
```

If the project does not build before the upgrade, stop and report — fix that first, separately.

## 3. Bump the dependency

In `Package.swift`, set `from: "<target version>"` on the Winged-Swift package, then:

```bash
swift package update Winged-Swift
grep -A3 '"winged-swift"' Package.resolved | grep version    # confirm the target resolved
```

Update the `winged` CLI too if the project uses it (build it from the matching tag).

## 4. Apply the documented rewrites

For **each** release between current and target, open its `MIGRATION.md` section and:

1. Run every `grep` it lists against `Sources/` (and `Tests/` if present).
2. Apply the before → after rewrite it shows, for every hit. Keep the change mechanical — do not
   refactor unrelated code in the same pass.
3. Note anything the section calls out as a **behaviour or output change** — you will look for it in
   the diff.

Then:

```bash
swift build 2>&1 | grep -E "error|warning: .*deprecated"
```

Errors must be zero. Deprecation warnings are allowed only if the target release still supports the
member; list them in your report and convert them when they are trivial.

Optional adoption sections ("what this release makes shorter") are **not** part of the upgrade. Only
apply them if the user asked for it, and as a separate commit after the diff is clean.

## 5. Diff the output

```bash
winged build
diff -r /tmp/winged-dist-before dist && echo "IDENTICAL"
```

- If the changelog says the release renders byte-identical output, the diff **must** be empty.
  Anything else is either a mistake in your rewrites or a library bug — investigate, do not commit.
- If the release documents an output change (escaping, whitespace, attribute order), every hunk
  must be explained by it. Summarise the hunks by kind ("142 files: `<br/>` → `<br>`"), not one by
  one.
- An unexplained hunk means stop and ask the user.

## 5b. Adopting a new model (only when asked)

Some releases add a new way to write a site that is not part of the upgrade — 2.2's `Site` /
`Page` model is the main one. When the user asks for it, after the upgrade is committed:

1. Record every URL the site serves now: `cd /tmp/winged-dist-before && find . -type f | sort`.
2. Follow the release's "Optional" section in `MIGRATION.md` (for 2.2, the script → `Site`
   mapping table). Set `path` on any page whose default slug would change its URL.
3. Rebuild and diff. Every old file must still exist. Differences must be limited to what the
   section names (for 2.2: `<head>` tags, `sitemap.xml`, `robots.txt`, a new `404.html`); body
   markup must not change.
4. Commit separately (`Change: move the site onto the WingedSwift Site model`).

## 6. Report and commit

Report: from → to version, files touched, rewrites applied (with counts), remaining deprecation
warnings, and the diff result. Commit only after the user has seen the diff summary, with a message
like `Change: upgrade WingedSwift to 2.1.0`.

## Version notes at a glance

These summarise `MIGRATION.md`. If they disagree, `MIGRATION.md` wins.

| Upgrade | Breaks source? | Output change? | Watch for |
| --- | --- | --- | --- |
| 1.x → 2.0 | No (deprecations only) | No | Swift 6.0 toolchain; `render(pretty:)` → `render(.pretty)`; subclasses overriding `renderCompact`/`renderPretty` must override `write(into:options:indentLevel:)` |
| 2.0 → 2.1 | Rarely | No — diff must be empty | `catch let e as CocoaError` around `StaticSiteGenerator` no longer matches (`WingedError`); your own `extension HTMLTag` named `target`/`rel`/`loading`/`decoding`/`hidden`/`tabIndex`/`lang` becomes ambiguous |
| 2.1 → 2.2 | No | No — diff must be empty | New names (`Site`, `Page`, `Environment`, …) only matter if you adopt the site model in a module that already has them; exhaustive `switch` over `WingedError` needs `.duplicatePath`. Moving a script onto `Site` is optional adoption and changes `<head>` — separate commit, keep every URL |
| 2.2 → 2.3 | No | No — diff must be empty | CLI only: `winged build` now runs `npm run build:css` (drop a duplicate step or pass `--skip-css`); `serve --watch` injects a reload script into *served* pages only |
| 2.3 → 2.4 | Rarely (`site.document(at:)` now `throws`) | No for scripts; a `Site` with a `Content/` folder gains pages | Check for an existing `Content/*.md` before upgrading a `Site`-model project; set `contentDirectory` to opt out |
| 2.0 → 2.4.0 (one release) | Apply the four rows above in order | — | 2.1–2.4 shipped together as 2.4.0 |
| 2.4 → 3.0 | Yes — compile errors with 1:1 replacements | Only for `javascript:`/`vbscript:`/`data:text/html` URLs (now `#`) and for `render()` after a global `xhtmlSelfClosing` flip | Clear every WingedSwift deprecation warning on 2.4 **first**; `WingedSwift.version` → `WingedSwiftVersion.current`; run the script-URL grep and mark intended ones `.trustedURL(...)` |
