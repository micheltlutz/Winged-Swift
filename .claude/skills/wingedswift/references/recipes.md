# Recipes

Copy-pasteable snippets. Every one of them compiles against WingedSwift 2.0.

## New site project

```bash
winged new MySite            # add --tailwind for a Tailwind setup
cd MySite
winged serve --watch         # http://localhost:8000, rebuilds on change
```

```
MySite/
├── Package.swift
├── AGENTS.md               # instructions for the next agent that opens this repo
├── Sources/MySite/
│   ├── main.swift          # the pages and where they are written
│   ├── SiteLayout.swift    # the shared shell
│   └── Components.swift    # content + reusable markup
├── assets/                 # css, js, images copied to the output
└── dist/                   # generated — gitignored
```

Doing it by hand instead:

```swift
// Package.swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MySite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "2.0.0")
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
winged build                                                 # 1. generate dist/
npx tailwindcss -i ./assets/css/tailwind.input.css \
                -o ./dist/css/style.css --minify             # 2. build the CSS
```

Running Tailwind before the generator produces a stylesheet missing every class, because the HTML it
scans does not exist yet.
