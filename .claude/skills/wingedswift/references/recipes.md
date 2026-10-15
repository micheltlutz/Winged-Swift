# Recipes

Copy-pasteable snippets. Every one of them compiles against WingedSwift 2.3; sections marked with a
version need at least that one.

## New site project

```bash
winged new MySite                      # landing page (default); add --tailwind for Tailwind
winged new MyBlog --template blog      # also: minimal, docs — `winged new --list-templates`
winged new MySite --template https://github.com/you/starter   # any git starter
cd MySite
winged serve --watch --open            # rebuilds and reloads the browser on every change
winged add page Pricing                # Sources/MySite/Pages/Pricing.swift
winged add component PriceCard         # Sources/MySite/Components/PriceCard.swift
winged deploy github-pages --workflow  # .github/workflows/deploy-pages.yml
```

```
MySite/                     # landing template
├── Package.swift
├── AGENTS.md               # instructions for the next agent that opens this repo
├── Sources/MySite/
│   ├── main.swift          # the Site — name, URL, pages, layout — and publish()
│   ├── Pages.swift         # one `Page` per page
│   ├── SiteLayout.swift    # the shared shell
│   └── Components.swift    # content + reusable markup
├── assets/                 # css, js, images copied to the output
└── dist/                   # generated — gitignored
```

A starter repository for `--template <url>` is any folder of files: `{{PROJECT_NAME}}`,
`{{SITE_TITLE}}`, `{{SITE_DESCRIPTION}}`, `{{SITE_LANG}}`, `{{YEAR}}`, `{{TODAY}}` and
`{{WINGED_VERSION}}` are replaced in file contents and in paths (`Sources/{{PROJECT_NAME}}/`), and
an optional `winged-template.json` with `{"message": "…"}` is printed after creation.

Doing it by hand instead:

```swift
// Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MySite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "2.4.0")
    ],
    targets: [
        .executableTarget(
            name: "MySite",
            dependencies: [.product(name: "WingedSwift", package: "Winged-Swift")]
        )
    ]
)
```

Do not add a `platforms:` clause unless you need one — it breaks Linux builds.

## A whole site (2.2+)

Declare the site and its pages as types; `publish()` writes pages, assets, head meta tags,
`404.html`, `sitemap.xml`, `robots.txt` and (with `feedItems`) a feed.

```swift
import WingedSwift

struct Home: Page {
    var title = "RideKeeper"
    var body: HTMLTag {
        H1(content: "Track every service")
    }
}

struct Pricing: Page {                      // served at /pricing/
    var title = "Pricing"
    var description = "Plans for every rider"
    var image = "/img/pricing.png"          // og:image, made absolute
    var body: HTMLTag { P(content: "Free while in beta.") }
}

struct MainLayout: PageLayout {
    func head() -> [HTMLTag] {
        Link(href: "/css/style.css", rel: "stylesheet")
    }

    func body(content: HTMLTag) -> [HTMLTag] {
        SiteNav()
        MainTag(children: [content])
    }
}

struct SiteNav: Component {
    @Environment(\.pages) var pages        // also \.site and \.page

    var body: HTMLTag {
        Nav {
            for page in pages where page.path != "/404.html" {
                A(href: page.path, content: page.title)
            }
        }
    }
}

struct RideKeeper: Site {
    var name = "RideKeeper"
    var url = "https://ridekeeper.example"
    var language = "pt-BR"
    var description = "Motorcycle maintenance companion"
    var homePage = Home()
    var layout = MainLayout()

    var pages: [any Page] {
        Pricing()
    }
}

try RideKeeper().publish()                 // dist/, or the path `winged build` passes
```

- Declare page and site properties with plain values (`var description = "…"`). The protocol
  types are non-optional on purpose, so inference always matches the requirement.
- `path` defaults to the type name (`Pricing` → `/pricing/`); set it to keep an existing URL
  (`var path = "/pricing.html"`).
- Do not put `<title>` or SEO meta in the layout — the site writes them.
- `site.document(at: "/pricing/")` renders one page without writing files, for tests.

## Markdown content (2.4+)

Put Markdown files in `Content/`; each becomes a page through the site layout.

~~~markdown
<!-- Content/posts/hello-world.md → /posts/hello-world/ -->
---
title: Hello, world
date: 2026-10-15
tags: swift, web
description: The first post.
---

Some **Markdown**, a [link](/about/) and code:

```swift
let site = Blog()
```
~~~

```swift
struct Home: Page {
    var title = "Blog"
    @Environment(\.content) var posts          // newest first

    var body: HTMLTag {
        Ul {
            for post in posts {
                Li { A(href: post.path, content: post.title) }
            }
        }
    }
}

struct PostLayout: ContentLayout {           // optional; DefaultContentLayout otherwise
    func body(page: ContentPage, content: HTMLTag) -> HTMLTag {
        Article {
            H1(content: page.title)
            P(content: "\(page.readingMinutes) min read")
            content
        }
    }
}

struct Blog: Site {
    var name = "Blog"
    var url = "https://blog.example"
    var homePage = Home()
    var layout = MainLayout()
    var contentLayout = PostLayout()
}
```

- Dated pages get a feed entry (when the site declares no `feedItems`), `og:type=article` and a
  sitemap `lastmod`; tagged pages get `/tags/<tag>/` pages (`generatesTagPages = false` to skip).
- `published: false` hides a draft; `path:` overrides the URL.
- Raw HTML in Markdown is escaped unless `markdownOptions = MarkdownOptions(rawHTML: true)`.
- Outside a site: `Div(children: Markdown.parse(text))`.

## A page

```swift
import WingedSwift

let home = Document(lang: "en") {
    Meta(charset: "UTF-8")
    Title(content: "Home")
    Link(href: "/css/style.css", rel: "stylesheet")
} body: {
    H1(content: "Hello")
    P(content: "Built with Swift.")
}

print(home.render())        // pretty by default, doctype included
print(home.render(.compact))
```

## A layout

Return a `Document` from a struct that owns the shell:

```swift
struct SiteLayout {
    let title: String
    let description: String

    func page(@HTMLFragmentBuilder content: () -> [HTMLTag]) -> Document {
        Document(lang: "en") {
            Fragment(children: SEO.common(title: title, description: description))
            Title(content: title)
            Link(href: "/css/style.css", rel: "stylesheet")
        } body: {
            Header {
                Nav {
                    A(href: "/", content: "My Site").addClass("logo")
                    Ul {
                        Li { A(href: "/", content: "Home") }
                        Li { A(href: "/about/", content: "About") }
                    }
                }
            }
            MainTag(children: content()).addClass("container")
            Footer { P(content: "© 2026") }
        }
    }
}

let page = SiteLayout(title: "Home", description: "Welcome").page {
    Section { H1(content: "Hello") }
}
```

The library's `Layout` protocol (`func render(content: HTMLTag) -> HTMLTag`) is still there for
1.x-style layouts that wrap a single tag.

## Writing the site to disk

```swift
let generator = StaticSiteGenerator(outputDirectory: "./dist")

try generator.clean()
try generator.generateMultiple(documents: [
    (document: home, path: "index.html"),
    (document: about, path: "about/index.html")
])
try generator.copyAsset(from: "./assets/css", to: "css")
try generator.copyAsset(from: "./assets/images", to: "images")
try generator.writeFile(content: "User-agent: *\nAllow: /", to: "robots.txt")
```

## SEO head

```swift
// Everything at once: charset, viewport, description, robots, Open Graph and Twitter cards
let page = Document(lang: "en") {
    Fragment(children: SEO.complete(
        title: "RideKeeper",
        description: "Motorcycle maintenance companion",
        image: "https://ridekeeper.example/og.jpg",
        url: "https://ridekeeper.example",
        keywords: ["swift", "motorcycle", "maintenance"],
        author: "Michel Lutz",
        twitterSite: "@micheltlutz"
    ))
    Title(content: "RideKeeper")
} body: {
    H1(content: "Track every service")
}

// Or piecemeal
let ogTags = SEO.openGraphArticle(
    title: "Building static sites in Swift",
    description: "A walkthrough",
    image: "https://example.com/post.jpg",
    url: "https://example.com/post",
    author: "Michel Lutz",
    publishedTime: "2026-08-11T10:00:00Z"
)
```

`SEO.*` returns `[Meta]`; wrap it in `Fragment(children:)` to drop it into a builder block.

## Components

```swift
enum Components {
    static func featureCard(icon: String, title: String, body: String) -> HTMLTag {
        Div {
            Span(content: icon).addClass("text-3xl")
            H3(content: title).addClass("text-xl font-bold text-white mt-4")
            P(content: body).addClass("text-gray-300 mt-2")
        }
        .addClass("p-6 bg-gray-800 rounded-lg hover:bg-gray-700 transition-colors")
    }

    static func featureGrid(_ features: [(String, String, String)]) -> HTMLTag {
        Section {
            Div {
                H2(content: "Features").addClass("text-4xl font-bold text-center mb-16")
                Div {
                    for feature in features {
                        featureCard(icon: feature.0, title: feature.1, body: feature.2)
                    }
                }
                .addClass("grid gap-8 md:grid-cols-2 lg:grid-cols-3")
            }
            .addClass("container mx-auto px-6 py-16")
        }
    }
}
```

### A component as a type (2.1+)

A `Component` is a type with an `@HTMLBuilder var body`. Use it inside any builder like a tag.

```swift
struct FeatureCard: Component {
    let icon: String
    let title: String
    let text: String

    var body: HTMLTag {
        Div {
            Span(content: icon).addClass("text-3xl")
            H3(content: title).addClass("text-xl font-bold")
            P(content: text).addClass("text-gray-300")
        }
        .addClass("p-6 bg-gray-800 rounded-lg")
    }
}

Div {
    for feature in features {
        FeatureCard(icon: feature.icon, title: feature.title, text: feature.text)
    }
}
```

## Text next to inline elements (2.1+)

A bare string in a builder is an escaped text node — no wrapping `<span>`:

```swift
P {
    "Read the "
    A(href: "/docs/", content: "docs")
    " or open an issue."
}
// <p>Read the <a href="/docs/">docs</a> or open an issue.</p>   (compact)
```

In pretty output each child goes on its own line; add `.inline()` (2.4+) after the paragraph to
keep it on one line wherever it is rendered.

## Typed attributes (2.1+)

```swift
A(href: "https://github.com/micheltlutz", content: "GitHub")
    .target(.blank)
    .rel([.noopener, .noreferrer, .me])
Img(src: "/img/hero.webp", alt: "Hero").loading(.lazy).decoding(.async)
Div { … }.hidden().tabIndex(-1).lang("pt-BR")
```

## Loops and conditionals

```swift
let navigation = Nav {
    for link in links {
        A(href: link.url, content: link.label).addClass("px-3")
    }
    if isBeta {
        Span(content: "beta").addClass("badge")
    }
}

// `map` works too
let list = Ul {
    posts.map { Li(content: $0.title) }
}

// optional tags and `if #available` (2.1+)
let badge: HTMLTag? = post.isNew ? Span(content: "new") : nil
let header = Header {
    H2(content: post.title)
    badge
}

// conditional attributes (2.1+)
let email = HTMLTag("input", attributes: {
    Attribute(key: "type", value: "email")
    if isRequired { Attribute.boolean("required") }
    if let placeholder { Attribute(key: "placeholder", value: placeholder) }
})
```

## Tables

```swift
let table = Table {
    Caption(content: "Monthly totals")
    Thead {
        Tr { Th(content: "Month"); Th(content: "Total") }
    }
    Tbody {
        for row in rows {
            Tr { Td(content: row.month); Td(content: row.total) }
        }
    }
    Tfoot {
        Tr { Td(content: "Sum"); Td(content: total) }
    }
}
.addClass("w-full text-left")
```

## Forms

```swift
let form = Form(attributes: [
    Attribute(key: "action", value: "/subscribe"),
    Attribute(key: "method", value: "post")
]) {
    Fieldset {
        Legend(content: "Newsletter")
        Label(for: "email", content: "Email")
        Input(type: "email", name: "email", attributes: [
            Attribute(key: "id", value: "email"),
            Attribute(key: "placeholder", value: "you@example.com"),
            .boolean("required")
        ])
        Select(name: "topic") {
            Optgroup(label: "Swift") {
                Option(value: "ios", content: "iOS")
                Option(value: "server", content: "Server-side")
            }
        }
        Textarea(name: "message", content: "")
        Button(type: "submit", content: "Subscribe")
    }
}
```

## Media

```swift
let hero = Picture {
    Source(srcset: "/img/hero.avif", type: "image/avif")
    Source(srcset: "/img/hero.webp", type: "image/webp")
    Img(src: "/img/hero.jpg", alt: "App running on an iPhone").addClass("w-full")
}

let demo = Video(src: "/media/demo.mp4", controls: true, muted: true, poster: "/img/poster.jpg") {
    Track(src: "/media/demo.vtt", srclang: "en", label: "English")
}

let map = Iframe(src: "https://maps.example/embed", title: "Office location")
```

## FAQ with `<details>`

```swift
let faq = Section {
    for question in questions {
        Details {
            Summary(content: question.title).addClass("cursor-pointer font-semibold")
            P(content: question.answer).addClass("mt-2 text-gray-300")
        }
        .addClass("py-4 border-b border-gray-800")
    }
}
```

## Sitemap and RSS

```swift
let sitemap = SitemapGenerator.generate(urls: [
    SitemapURL(loc: "https://example.com/", changefreq: "daily", priority: 1.0),
    SitemapURL(loc: "https://example.com/blog", lastmod: "2026-08-11", priority: 0.8)
])
try generator.writeFile(content: sitemap, to: "sitemap.xml")

let feed = RSSGenerator(
    title: "My Blog",
    link: "https://example.com",
    description: "Posts about Swift",
    language: "pt-BR"
).generate(items: posts.map {
    RSSItem(title: $0.title, link: $0.url, description: $0.summary, pubDate: $0.rfc822Date)
})
try generator.writeFile(content: feed, to: "feed.xml")
```

## Syntax-highlighted code blocks

Markdown fences already carry the class highlighters look for — ```` ```swift ```` renders
`<pre><code class="language-swift">`; include Prism or highlight.js in the layout's `head()`.


```swift
let snippet = Pre {
    Code(attributes: [Attribute(key: "class", value: "language-swift")],
         content: "let page = Document { } body: { }")
}
```

`<pre>` and `<code>` are never re-indented by `render(.pretty)`, so the displayed code stays exactly
as written.

## Embedding raw markup

```swift
let icon = RawHTML("""
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" width="24" height="24">
  <path d="M4 12h16M12 4v16"/>
</svg>
""")

let analytics = Script(content: """
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
""")
```

## Custom render options

```swift
page.render(.compact)                                   // ship this
page.render(.pretty)                                    // read this
page.render(RenderOptions(pretty: true, indent: "\t"))  // tabs
page.render(RenderOptions(xhtmlSelfClosing: true))      // <img … />
```

Options are a value: two tasks can render the same tree differently at the same time.

## Tailwind CSS workflow

WingedSwift emits the classes; Tailwind scans the generated HTML for them.

```ts
// tailwind.config.ts — scan the OUTPUT, not the Swift sources
export default {
  content: ["./dist/**/*.html"],
  theme: { extend: {} }
}
```

```bash
npm install    # once
winged build   # generates dist/, then runs the package.json `build:css` script (2.3+)
```

`winged build` runs Tailwind *after* the generator on purpose: run before it, Tailwind produces a
stylesheet missing every class, because the HTML it scans does not exist yet. `--skip-css` turns
the step off; without `winged`, run `npm run build:css` after generating.
