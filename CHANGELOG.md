# Changelog

All notable changes to WingedSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

