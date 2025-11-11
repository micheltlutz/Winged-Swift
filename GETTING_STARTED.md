# 🚀 Getting Started - Building Your First WingedSwift Project

This guide walks you through creating a project from scratch using WingedSwift to generate static sites.

## 📋 Prerequisites

- Swift 5.9 or newer
- Xcode or the Swift command-line tools installed

Check your version:
```bash
swift --version
```

---

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
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MySwiftSite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.3")
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

// 3. Create the home page
let homePage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
        Title(content: "My First Site with WingedSwift")
    ])
    
    Body(children: [
        Header(children: [
            H1(content: "🎉 Welcome to WingedSwift!")
        ])
        .addClass("header"),
        
        MainTag(children: [
            Article(children: [
                H2(content: "About this site"),
                P(content: "This is a static site generated with Swift using WingedSwift!"),
                P(content: "It’s fast, type-safe, and fun to build.")
            ])
        ])
        .addClass("container"),
        
        Footer(children: [
            P(content: "Built with ❤️ using WingedSwift")
        ])
        .addClass("footer")
    ])
}

// 4. Generate the HTML
try generator.generate(page: homePage, to: "index.html", pretty: true)

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

# Or serve with Python (simple HTTP server)
cd dist
python3 -m http.server 8000
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

class BaseLayout: Layout {
    let title: String
    let description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    func render(content: HTMLTag) -> HTMLTag {
        return html {
            Head(children: [
                Meta(charset: "UTF-8"),
                Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
                Meta(name: "description", content: description),
                Title(content: title),
                Link(href: "css/style.css", rel: "stylesheet")
            ])
            
            Body(children: [
                Header(children: [
                    H1(content: title)
                ])
                .addClass("header"),
                
                content,
                
                Footer(children: [
                    P(content: "© 2024 My Site. Built with WingedSwift 🚀")
                ])
                .addClass("footer")
            ])
        }
    }
}
```

#### 4. `Sources/Pages/HomePage.swift`

```swift
import WingedSwift

struct HomePage {
    static func create(layout: BaseLayout) -> HTMLTag {
        let content = MainTag(children: [
            Article(children: [
                H2(content: "Welcome!"),
                P(content: "This is a sample site generated with WingedSwift."),
                P(content: "You can build amazing static sites using Swift!")
            ])
        ])
        .addClass("container")
        
        return layout.render(content: content)
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
try generator.generate(page: home, to: "index.html", pretty: true)
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

## 🌐 Method 3: Project with Live Server

### Add a Development Script

Create `Scripts/dev.sh`:

```bash
#!/bin/bash

echo "🔨 Building and generating the site..."
swift run

echo "🌐 Starting local server..."
echo "📱 Open: http://localhost:8000"
cd dist && python3 -m http.server 8000
```

Make it executable:

```bash
chmod +x Scripts/dev.sh
```

Run it:

```bash
./Scripts/dev.sh
```

### Watch Mode (Optional)

Install `fswatch`:

```bash
brew install fswatch
```

Create `Scripts/watch.sh`:

```bash
#!/bin/bash

echo "👀 Watching for changes..."

fswatch -o Sources/ | while read f; do
    echo "♻️  Changes detected, rebuilding..."
    swift run
    echo "✅ Site regenerated!"
done
```

Run it:

```bash
chmod +x Scripts/watch.sh
./Scripts/watch.sh &
cd dist && python3 -m http.server 8000
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

// Home
let homePage = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "Latest Posts"),
        Ul(children: [
            Li(children: [A(href: "post1.html", content: "My First Post")]),
            Li(children: [A(href: "post2.html", content: "Learning Swift")]),
            Li(children: [A(href: "about.html", content: "About Me")])
        ])
    ])
]).addClass("container"))

// Post 1
let post1 = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "My First Post"),
        Time(datetime: "2024-10-16", content: "October 16, 2024"),
        P(content: "This is my first post created with WingedSwift!"),
        A(href: "index.html", content: "← Back")
    ])
]).addClass("container"))

// About
let aboutPage = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "About Me"),
        P(content: "Swift developer passionate about building static sites!"),
        A(href: "index.html", content: "← Back")
    ])
]).addClass("container"))

// === GENERATE ===
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: post1, to: "post1.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

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

```swift
// For larger sites, generate in parallel
let pages = [(home, "index.html"), (about, "about.html")]

DispatchQueue.concurrentPerform(iterations: pages.count) { index in
    let (page, path) = pages[index]
    try? generator.generate(page: page, to: path, pretty: true)
}
```

### Debug

```swift
// Inspect the generated HTML
let page = html { /* ... */ }
print(page.render(pretty: true))
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

