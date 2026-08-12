# 🚀 Getting Started - Building Your First WingedSwift Project

This guide walks you through creating a project from scratch using WingedSwift to generate static sites.

## 📋 Prerequisites

- Swift 6.0 or newer (Xcode 16+)
- Xcode or the Swift command-line tools installed

Check your version:
```bash
swift --version
```

---

## ⚡️ Method 0: The `winged` CLI (fastest)

```bash
winged new MySwiftSite      # add --tailwind for a Tailwind setup
cd MySwiftSite
winged serve --watch        # http://localhost:8000, rebuilds on every change
```

That scaffolds `Package.swift`, a layout, components, assets and an `AGENTS.md`. The rest of this
guide builds the same thing by hand, so you know what each piece does.

## 🎯 Method 1: Minimal Project (Recommended for Beginners)

### Step 1: Create the Project Directory

```bash
# Create the project directory
mkdir MySwiftSite
cd MySwiftSite
```

### Step 2: Initialize the Swift Package

```bash
# Create a Swift executable
swift package init --type executable

# Generated structure:
# MySwiftSite/
# ├── Package.swift
# ├── Sources/
# │   └── main.swift
# └── Tests/
```

### Step 3: Configure `Package.swift`

Edit the `Package.swift` file:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MySwiftSite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MySwiftSite",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ]
        )
    ]
)
```

### Step 4: Create Your Site (`Sources/main.swift`)

Replace the contents of `Sources/main.swift`:

```swift
import Foundation
import WingedSwift

// 1. Configure the static site generator
let generator = StaticSiteGenerator(outputDirectory: "./dist")

// 2. Clean the output directory
try generator.clean()

// 3. Create the home page.
//    `Document` owns the doctype and the <html lang="…"> element; each container takes its
//    children as a trailing closure, where `if`, `for` and `map` all work.
let homePage = Document(lang: "en") {
    Meta(charset: "UTF-8")
    Meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
    Title(content: "My First Site with WingedSwift")
} body: {
    Header {
        H1(content: "🎉 Welcome to WingedSwift!")
    }
    .addClass("header")

    MainTag {
        Article {
            H2(content: "About this site")
            P(content: "This is a static site generated with Swift using WingedSwift!")
            P(content: "It’s fast, type-safe, and fun to build.")
        }
    }
    .addClass("container")

    Footer {
        P(content: "Built with ❤️ using WingedSwift")
    }
    .addClass("footer")
}

// 4. Generate the HTML
try generator.generate(document: homePage, to: "index.html")

print("✅ Site successfully generated at ./dist/index.html")
```

### Step 5: Build and Generate the Site

```bash
# Build and run
swift run

# Output: ✅ Site successfully generated at ./dist/index.html
```

### Step 6: Preview the Site

```bash
# Open in the browser
open dist/index.html

# Or serve it (and rebuild on every change)
winged serve --watch
# Visit: http://localhost:8000
```

---

## 🎨 Method 2: Full Project with CSS

### Organized Structure

```bash
MySwiftSite/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── Pages/
│   │   ├── HomePage.swift
│   │   └── AboutPage.swift
│   └── Layouts/
│       └── BaseLayout.swift
├── Assets/
│   ├── css/
│   │   └── style.css
│   └── images/     # Optional assets
└── dist/           # Generated automatically
```

### Complete Setup

#### 1. `Package.swift` (same as Method 1)

#### 2. `Assets/css/style.css`

```css
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    color: #333;
}

.header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 2rem;
    text-align: center;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

article {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.footer {
    background: #333;
    color: white;
    text-align: center;
    padding: 1rem;
    margin-top: 2rem;
}
```

#### 3. `Sources/Layouts/BaseLayout.swift`

```swift
import WingedSwift

/// Returns a `Document`, so it does not need the `Layout` protocol (which wraps a single tag).
struct BaseLayout {
    let title: String
    let description: String
    
    func page(@HTMLFragmentBuilder content: () -> [HTMLTag]) -> Document {
        Document(lang: "en") {
            Meta(charset: "UTF-8")
            Meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
            Meta(name: "description", content: description)
            Title(content: title)
            Link(href: "/css/style.css", rel: "stylesheet")
        } body: {
            Header {
                H1(content: title)
            }
            .addClass("header")

            MainTag(children: content()).addClass("container")

            Footer {
                P(content: "© 2026 My Site. Built with WingedSwift 🚀")
            }
            .addClass("footer")
        }
    }
}
```

#### 4. `Sources/Pages/HomePage.swift`

```swift
import WingedSwift

struct HomePage {
    static func create(layout: BaseLayout) -> Document {
        layout.page {
            Article {
                H2(content: "Welcome!")
                P(content: "This is a sample site generated with WingedSwift.")
                P(content: "You can build amazing static sites using Swift!")
            }
        }
    }
}
```

#### 5. `Sources/main.swift`

```swift
import Foundation
import WingedSwift

// Configuration
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

// Layout
let layout = BaseLayout(
    title: "My Swift Site",
    description: "Static site generated with WingedSwift"
)

// Pages
let home = HomePage.create(layout: layout)

// Generate
try generator.generate(document: home, to: "index.html")
try generator.copyAsset(from: "./Assets/css", to: "css")

print("✅ Site generated successfully!")
print("📂 Open: dist/index.html")
```

#### 6. Run

```bash
swift run
open dist/index.html
```

---

## 🌐 Method 3: Live Preview

The CLI has a server and a file watcher built in — no script, no Python:

```bash
winged serve --watch
# ▶ Building MySwiftSite
# ✅ Serving dist/ on http://localhost:8000
#    Watching for changes — Ctrl-C to stop.
```

Every save to `Sources/` or `assets/` regenerates the site; refresh the page to see it.

### Watch Mode Without the CLI

If you would rather not use `winged serve`, `fswatch` plus any static server works:

```bash
fswatch -o Sources/ assets/ | while read _; do swift run; done
```

---

## 📦 Complete Multi-Page Sample Project

### `Sources/main.swift`

```swift
import Foundation
import WingedSwift

// === CONFIGURATION ===
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

let layout = BaseLayout(
    title: "My Swift Blog",
    description: "A blog created with WingedSwift"
)

// === PAGES ===

let posts = [
    (slug: "post1.html", title: "My First Post"),
    (slug: "post2.html", title: "Learning Swift")
]

// Home
let homePage = layout.page {
    Article {
        H2(content: "Latest Posts")
        Ul {
            for post in posts {
                Li { A(href: post.slug, content: post.title) }
            }
            Li { A(href: "about.html", content: "About Me") }
        }
    }
}

// Post 1
let post1 = layout.page {
    Article {
        H2(content: "My First Post")
        Time(datetime: "2026-08-11", content: "August 11, 2026")
        P(content: "This is my first post created with WingedSwift!")
        A(href: "index.html", content: "← Back")
    }
}

// About
let aboutPage = layout.page {
    Article {
        H2(content: "About Me")
        P(content: "Swift developer passionate about building static sites!")
        A(href: "index.html", content: "← Back")
    }
}

// === GENERATE ===
try generator.generateMultiple(documents: [
    (document: homePage, path: "index.html"),
    (document: post1, path: "post1.html"),
    (document: aboutPage, path: "about.html")
])

// Copy assets
try generator.copyAsset(from: "./Assets/css", to: "css")

// SEO: Sitemap
let urls = [
    SitemapURL(loc: "https://my-site.com/", priority: 1.0),
    SitemapURL(loc: "https://my-site.com/post1.html", priority: 0.8),
    SitemapURL(loc: "https://my-site.com/about.html", priority: 0.7)
]
let sitemap = SitemapGenerator.generate(urls: urls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

print("✅ Complete site generated!")
print("📄 Pages: index.html, post1.html, about.html")
print("🗺️  Sitemap: sitemap.xml")
```

---

## 🚀 Deployment

### GitHub Pages

```bash
# Generate the site
swift run

# Commit and push
git add dist/
git commit -m "Deploy site"
git subtree push --prefix dist origin gh-pages
```

### Netlify

1. Create `netlify.toml`:

```toml
[build]
  command = "swift run"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

2. Connect your repository in Netlify
3. Automatic deploy!

### Vercel

```json
{
  "builds": [
    {
      "src": "Package.swift",
      "use": "@vercel/swift"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/dist/$1"
    }
  ]
}
```

---

## 📚 Next Steps

1. **Explore Examples**: See [EXAMPLE.md](EXAMPLE.md)
2. **Read the Documentation**: [README.md](README.md)
3. **Check the Demo**: [WingedSwiftDemoVapor](https://github.com/micheltlutz/WingedSwiftDemoVapor)
4. **Contribute**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 💡 Tips

### Performance

Rendering writes into a single buffer, so a page costs one allocation rather than one per tag —
generating sequentially is fast enough for thousands of pages.

A tag tree is a mutable object graph and deliberately not `Sendable`: if you do parallelise, build
and render each page inside its own task and move only the resulting `String` between them.

```swift
let rendered = await withTaskGroup(of: (String, String).self) { group in
    for (page, path) in pages {
        group.addTask { (page.render(.pretty), path) }   // page built inside this task
    }
    return await group.reduce(into: [(String, String)]()) { $0.append($1) }
}

for (html, path) in rendered {
    try generator.writeFile(content: html, to: path)
}
```

### Debug

```swift
// Inspect the generated HTML
let page = Document { Title(content: "T") } body: { H1(content: "Hi") }
print(page.render(.pretty))
```

### Reuse

```swift
// Create reusable components
func createCard(title: String, content: String) -> Div {
    return Div(children: [
        H3(content: title),
        P(content: content)
    ]).addClass("card")
}
```

---

## 🆘 Common Issues

**Error: "No such module 'WingedSwift'"**  
- Run: `swift package resolve`

**Site does not update**  
- Delete `.build` and rebuild: `rm -rf .build && swift run`

**CSS not loading**  
- Check the relative path in `Link(href: "css/style.css")`
- Ensure assets are copied with `generator.copyAsset()`

---

## 📞 Support

- 📖 Documentation: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/micheltlutz/Winged-Swift/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/micheltlutz/Winged-Swift/discussions)

**Have fun building sites with Swift! 🚀**

