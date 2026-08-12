# Changelog

All notable changes to WingedSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-08-11

Nothing was removed: every 1.x call site still compiles and renders byte-identical markup, covered
by `DeprecatedAPITests`. See [MIGRATION.md](MIGRATION.md).

### Added

- **Result-builder initializers on every container** — `Div { H1(...) ; P(...) }`, with `if`, `for`
  and `map` supported inside. The array form is unchanged.
- **`Document`**: owns `<!DOCTYPE html>` and `<html lang="…">`.
  `Document(lang:head:body:)` and a two-builder form (`Document { head } body: { body }`), plus
  `StaticSiteGenerator.generate(document:to:options:)`.
- **`RenderOptions`**: `pretty`, `indent` and `xhtmlSelfClosing` passed per call —
  `render(.pretty)`, `render(RenderOptions(indent: "\t"))`.
- **`winged` CLI**: `winged new` (scaffolds a project, including its own `AGENTS.md`),
  `winged build`, `winged serve [--watch]` with a built-in static server. Replaces the StarterKit's
  `setup.sh` and `python3 -m http.server`.
- **`MIGRATION.md`** and `Scripts/generate-builder-inits.py`.
- **Golden-file tests**: full pages, sitemap and feed frozen under `Tests/WingedSwiftTests/Fixtures`
  (`WINGED_UPDATE_FIXTURES=1 swift test` to regenerate), plus a render-performance guard.
- `Pre`, `Code`, `Figcaption`, `Mark` and `Time` accept `children:`.

### Changed

- **Swift 6.0+ required**: `swift-tools-version: 6.0`, language mode 6, no concurrency diagnostics.
  CI moved to `macos-14` and the `swift:6.0` container.
- **Rendering writes into one buffer** (`write(into:options:indentLevel:)`) instead of concatenating
  a string per node. This is now the overridable primitive — a subclass that overrode
  `renderCompact()` / `renderPretty(_:)` must override `write` instead.
- **`Sendable`** on `Attribute`, `RenderOptions`, `HTMLEscape`, `SEO`, `SitemapURL`,
  `SitemapGenerator`, `RSSItem`, `RSSGenerator` and `StaticSiteGenerator`; the last two are now
  `final`. `HTMLTag` and `Document` are deliberately not `Sendable`.
- **`HTMLFragmentBuilder`**: one `buildBlock` and a generic `buildExpression<Tag: HTMLTag>([Tag])`,
  so `Ol { ["x", "y"].map { Li(content: $0) } }` compiles instead of reporting an ambiguity.
- Pretty printing now emits `content` *and* `children` when both are set; it used to drop the text.
- The test suite moved to Swift Testing (`@Suite` / `@Test` / `#expect`); `DeprecatedAPITests`
  stays on XCTest so the deprecated API can be exercised without warnings.

### Deprecated

Removed in 3.0 — `render(pretty:indentLevel:)`, `renderCompact()`, `renderPretty(indentLevel:)`,
`HTMLTag.xhtmlSelfClosing`, and the unlabelled `HTMLTag(_:_:)` attributes-builder initializer
(use `HTMLTag(_:attributes:)`).

## [1.5.0] - 2026-08-11

### Added

- **`Fragment`**: a transparent node that renders its children with no wrapper element, keeping
  pretty-print indentation (unlike `RawHTML`, which flattens to a raw string).
- **Tables**: `Thead`, `Tbody`, `Tfoot`, `Caption`, `Colgroup`, `Col`.
- **Media**: `Picture`, `Video`, `Audio`, `Source`, `Track`, `Iframe`, `Canvas`.
- **Text & interactive**: `Blockquote`, `Q`, `Cite`, `Abbr`, `Address`, `Sub`, `Sup`, `Del`, `Ins`,
  `Kbd`, `Samp`, `VarTag` (`<var>`), `Details`, `Summary`, `Dialog`, `Dt`, `Dd`, `Style`, `Base`,
  `Noscript`, `Wbr`.
- **Forms**: `Legend`, `Optgroup`, `Datalist`, `Progress`, `Meter`, `Output`.
- **`Pre`** and **`Code`**: accept `children:` (the `<pre><code>` highlighting pattern).
- **Flow containers** `Article`, `Aside`, `Header`, `Footer`, `MainTag`, `Nav`, `Figure`, `Form` and
  `Fieldset`: accept `content:` / `escapeContent:` like `Div`, instead of `children:` only.
- **`HTMLBuilder`**: `buildArray` / `buildExpression`, so `for` loops work inside `html { }`.
- **`AGENTS.md`**, **`ROADMAP.md`**, `Scripts/verify.sh` and `Scripts/generate-tag-catalog.sh`:
  onboarding for coding agents and a single command to verify a change.

### Fixed

- **Stray `<html>` nodes**: an `if` inside `html { }` emitted `<html></html>` when the condition was
  false, and the body of an `if` / `for` block was wrapped in its own `<html>` element. `buildBlock`
  now produces a `Fragment` and `html(_:)` owns the root element.
- **Void elements**: `area`, `base`, `col`, `source`, `track` and `wbr` were rendered with a closing
  tag (`<col></col>`).
- **Pretty printing inside `<pre>`, `<code>` and `<textarea>`**: indentation was injected into
  whitespace-sensitive content, changing what the browser displays. These subtrees now render
  compactly even in pretty mode.
- **Attribute injection**: `addClass`, `setId` and `setStyle` wrote values verbatim, so a quote in
  dynamic data escaped the attribute. Values are escaped now, without double-escaping `&` on
  repeated `addClass` calls.

### Changed

- **`HTMLEscape.escape`** no longer escapes `/` by default — `&`, `<`, `>`, `"` and `'` already
  close the XSS surface, and escaping every slash turned dates and paths into `&#x2F;` soup. Pass
  `escapeSlashes: true` for the previous behaviour.
- **Chaining preserves the concrete type**: `addClass`, `addClasses`, `setId`, `setStyle`,
  `dataAttribute(s)`, `ariaAttribute(s)`, `setRole` and `setAttribute` return `Self` instead of
  `HTMLTag`, so `Div().addClass("card")` is still a `Div`.
- **`fragment { }`** returns a `Fragment` instead of a `RawHTML`. `RawHTML` remains for raw markup.
- **`Attribute`** is a `struct` instead of a `class`.
- **`Section`** moved from `HTML/Forms/` to `HTML/Commons/` (no API change).
- **`WingedSwift`**: added `version`, `author` and `contact` static properties.

## [1.4.0] - 2026-07-15

### Added

- **`RawHTML`**: render raw markup without a wrapper element (fragments / imported HTML).
- **`Attribute.boolean(_:)`**: boolean attributes render as ` key` only (`hidden`, `checked`, `required`, `disabled`, …).
- **`HTMLFragmentBuilder`** + **`fragment { }`**: build flat tag lists; `buildArray` supports `map`/`for` of cards and filters.
- New tags: **`I`**, **`Br`**, **`Hr`**, **`Strong`**, **`Em`**, **`Small`**.
- **`A`** and **`H1`…`H6`**: accept `children: [HTMLTag]` (e.g. `<h3><a>…</a></h3>`, `<a><img></a>`).

### Changed

- **HTML5 void elements** by default: `<img>`, `<br>`, `<input>`, etc. without trailing ` />`. Set `HTMLTag.xhtmlSelfClosing = true` for XHTML-style output.
- **`Button`**: optional `type` (`button` / `submit` / `reset`); no longer unconditionally forces `type="button"` when a type is already present or `nil` is passed.
- **`Label`**: `for` is optional (CMP / wrapping labels).
- **`Input`**: `name` is optional.
- **`Section`**: aligned with `Div` (`content` + `escapeContent`).

### Tests

- Unit coverage for RawHTML, boolean attrs, HTML5/XHTML self-closing, fragments + `buildArray`, `I` + `A(children:)`, flexible form tags.

## [1.3.2] - 2024-10-17

### Fixed

#### Cross-Platform Compatibility
- **Package.swift**: Updated `swift-tools-version` from 5.5 to 5.9 for better compatibility
- **Removed platforms restriction**: All example projects now omit `platforms` field to ensure cross-platform compatibility (macOS, Linux, Windows)
- **Package.swift syntax**: Corrected dependency syntax in all documentation to use `.product(name: "WingedSwift", package: "Winged-Swift")` instead of string literal
- **StarterTemplate**: Fixed Package.swift to work on all platforms

#### GitHub Actions CI/CD
- **Xcode compatibility**: Changed from `macos-latest` to `macos-13` to avoid Xcode 16.4 SDK issues
- **Linux tests**: Replaced `swift-actions/setup-swift` with official Swift Docker containers (`swift:5.10`)
- **Split test jobs**: Separated into `test-macos` and `test-linux` for better reliability
- **Coverage job**: Added error handling and `continue-on-error` for robustness
- **Lint job**: Updated to use `brew install swiftlint` directly

#### Code Quality
- **SwiftLint**: Fixed all 44 violations (trailing newlines, type names, etc.)
- **SwiftLint config**: 
  - Updated `type_name` min_length to 1 (allow HTML tag names: A, P, H1, H2, etc.)
  - Disabled `inclusive_language` rule (RSS 2.0 spec requires `webMaster` XML tag)
- **RSSGenerator**: Renamed parameter from `webMaster` to `webmaster` (camelCase)
- **Trailing newlines**: Auto-fixed in all source and test files

#### Template & Documentation
- **StarterTemplate**: Fixed `createFeatureCard` return type from `Div` to `HTMLTag`
- **StarterTemplate**: Changed `Main()` to `MainTag()` (correct class name)
- **StarterTemplate**: Updated asset copy to use specific directories instead of root
- **Examples**: Fixed `escapeContent` parameter usage in A tag (not supported)

### Changed

#### Documentation Organization
- **CONTRIBUTING.md**: Completely rewritten with comprehensive 696-line guide including:
  - Complete development workflow
  - Commit message guidelines
  - Code style standards
  - Testing requirements
  - Pull request process
  - Bug/Feature report templates
  - Docker testing instructions
  - Recognition and Code of Conduct
  
- **README.md**: Streamlined and reorganized (reduced from 978 to 761 lines):
  - Removed duplicate contributing content
  - Added "Platform Support" section
  - Updated Table of Contents
  - Cleaner contributing section with link to CONTRIBUTING.md
  - Better organization of sections

#### New Documentation Files
- **GETTING_STARTED.md** (488 lines): Complete step-by-step tutorial with 3 different methods
- **QUICK_START_GUIDE.md** (268 lines): 3-command quick start for absolute beginners
- **READY_TO_PUBLISH.md** (339 lines): Final publish guide with complete validation
- **SUMMARY.md** (253 lines): Project overview and statistics
- **RELEASE_CHECKLIST.md** (282 lines): Complete release process guide
- **FINAL_INSTRUCTIONS.md** (257 lines): Publishing instructions

#### Platform Support
- **Explicitly documented**: macOS, Linux, and Windows support
- **CI testing**: GitHub Actions now tests on both Ubuntu (Linux) and macOS
- **Best practices**: Documentation includes cross-platform guidelines

### Added

#### Developer Experience
- **Starter Template improvements**: 
  - README with complete instructions
  - Build, dev, and deploy scripts
  - Example of using local package path
  
- **Better examples**: All code examples now use correct syntax and work out of the box
- **Multiple guides**: Different learning paths for different user levels

#### Contact Information
- Updated author contact information
- Added LinkedIn profile
- Direct email contact

### Documentation

- **9 comprehensive guides** covering all aspects of the library
- **Complete workflow documentation** in .github/workflows/README.md
- **SwiftLint configuration** documented and explained
- **Cross-platform testing** instructions with Docker

### Infrastructure

- **GitHub Actions optimized** for reliability and speed
- **Official Swift Docker images** for Linux CI
- **Error handling improved** in all workflows
- **Workflow documentation** added

### Notes

This release focuses on **polish, documentation, and cross-platform reliability**. All issues found during initial v1.3.0 testing have been resolved. The project is now production-ready with:
- ✅ Zero SwiftLint violations
- ✅ 65 tests passing on macOS and Linux
- ✅ Complete cross-platform support
- ✅ Comprehensive documentation
- ✅ Ready-to-use starter template
- ✅ Optimized CI/CD pipelines

## [1.3.0] - 2024-10-16

### Added

#### Core Features
- **Pretty Print**: Added `render(pretty: Bool)` method for formatted HTML output with proper indentation
- **HTML Escape**: Automatic XSS protection with content escaping (enabled by default, can be disabled with `escapeContent: false`)
- **HTMLEscape** utility for manual escaping of HTML content and attributes

#### HTML5 Tags
- `Article` - Semantic article tag
- `Aside` - Sidebar/related content tag
- `Figure` - Self-contained content tag
- `Figcaption` - Caption for figure elements
- `Time` - Date/time semantic tag with datetime attribute support
- `Mark` - Highlighted text tag
- `H1`, `H2`, `H3`, `H4`, `H5`, `H6` - Heading tags

#### CSS & Styling Helpers
- `addClass(_ className: String)` - Add single CSS class
- `addClasses(_ classNames: [String])` - Add multiple CSS classes
- `setId(_ id: String)` - Set element ID
- `setStyle(_ style: String)` - Add inline styles

#### Accessibility & Data Attributes
- `dataAttribute(key: value:)` - Add data attributes
- `dataAttributes(_ data: [String: String])` - Add multiple data attributes
- `ariaAttribute(key: value:)` - Add ARIA attributes
- `ariaAttributes(_ aria: [String: String])` - Add multiple ARIA attributes
- `setRole(_ role: String)` - Set ARIA role
- `setAttribute(key: value:)` - Set custom attributes

#### SEO Features
- **SEO Helpers** struct with methods:
  - `SEO.openGraph()` - Generate Open Graph meta tags
  - `SEO.openGraphArticle()` - Generate article-specific OG tags
  - `SEO.twitterCard()` - Generate Twitter Card meta tags
  - `SEO.common()` - Generate standard SEO meta tags
  - `SEO.complete()` - All-in-one SEO meta tags (Common + OG + Twitter)
- **Meta Tag** enhancements:
  - Support for `property` attribute (Open Graph)
  - Support for `charset` attribute
  - Support for `http-equiv` attribute

#### Static Site Generation
- **StaticSiteGenerator** class for generating static websites:
  - `generate(page: to: pretty: doctype:)` - Generate single HTML file
  - `generateMultiple(_ pages:)` - Generate multiple pages at once
  - `copyAsset(from: to:)` - Copy assets (CSS, JS, images)
  - `clean(createDirectory:)` - Clean output directory
  - `writeFile(content: to:)` - Write arbitrary files (sitemap, RSS, etc.)

#### Layout System
- **Layout** protocol for creating reusable page templates
- Extension with `render(contents:)` for multiple content elements

#### Additional Generators
- **SitemapGenerator** for creating XML sitemaps:
  - `generate(urls:)` - Generate sitemap.xml
  - `generateIndex(sitemaps:)` - Generate sitemap index
  - `SitemapURL` struct for URL entries
- **RSSGenerator** for creating RSS 2.0 feeds:
  - `generate(items:)` - Generate RSS feed
  - `RSSItem` struct for feed items
  - Support for categories, authors, and GUIDs

#### Testing
- Comprehensive test coverage for all new features:
  - `PrettyPrintTests` - HTML formatting tests
  - `HTMLEscapeTests` - Security and escaping tests
  - `CSSHelpersTests` - CSS manipulation tests
  - `AttributeHelpersTests` - Data and ARIA attribute tests
  - `HTML5TagsTests` - New HTML5 tag tests
  - `SEOTests` - SEO helper tests

### Changed
- Updated `HTMLTag` init to support `escapeContent` parameter
- Updated `Attribute` init to support `escape` parameter
- Updated `Meta` class with multiple initializers for different use cases
- Updated `Script` tag to not escape content by default (JavaScript code)
- All content-bearing tags now support `escapeContent` parameter
- Improved documentation with extensive examples

### Security
- **XSS Protection**: All user content is now automatically escaped by default
- Attribute values are also escaped to prevent injection attacks

### Platform Support
- **Cross-Platform**: Fully compatible with macOS, Linux, and Windows
- Uses only Foundation APIs (no platform-specific code)
- CI tests run on both Ubuntu and macOS
- Perfect for server-side Swift deployments

### Documentation
- Completely updated README with:
  - Pretty print examples
  - Security best practices
  - CSS helpers usage
  - Data attributes and ARIA examples
  - HTML5 semantic tags examples
  - SEO helpers documentation
  - Static site generation tutorial
  - Layout system guide
  - Comprehensive feature list
- Added inline documentation for all new classes and methods

## [1.2.2] - Previous Version

Previous releases... (existing changelog content)

