# WingedSwift

![main](https://github.com/micheltlutz/Winged-Swift/actions/workflows/tests.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/micheltlutz/Winged-Swift/graph/badge.svg?token=3pxQp1KgnV)](https://codecov.io/gh/micheltlutz/Winged-Swift)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)


![Swift Versions](https://img.shields.io/badge/Swift-5.5%2B-orange.svg?style=flat)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/micheltlutz/Winged-Swift/badge?type=platforms)](https://swiftpackageindex.com/micheltlutz/Winged-Swift)


[![](https://img.shields.io/endpoint?url=https://swiftpackageindex.com/api/packages/micheltlutz/Winged-Swift/badge?type=swift-versions)](https://swiftpackageindex.com/micheltlutz/Winged-Swift)


# =============

**WingedSwift** is an innovative, **open-source** Domain-Specific Language (DSL) library for efficient HTML writing in Swift. Mirroring its Python counterpart, WingedSwift is based on the DSL concept, focusing on simplification and specificity in HTML generation. Using the Composite design pattern, the library enables developers to construct HTML structures in a logical, organized, and reusable manner.

This library is created to be fully independent, not requiring integration with specific server frameworks or front-end libraries. This offers developers the freedom to use WingedSwift across a variety of projects, from simple static pages to complex web applications, keeping the code clean, readable, and efficient.

## 🌟 Why WingedSwift?

- 🎯 **Type-Safe**: Leverage Swift's powerful type system
- 🔒 **Secure**: Built-in XSS protection
- 🚀 **Fast**: Compile-time HTML generation
- 🎨 **Modern**: Full HTML5 support with semantic tags
- 📱 **SEO-Ready**: Built-in Open Graph and Twitter Cards
- 🛠️ **Static Sites**: Complete static site generation tools
- 🤝 **Open Source**: MIT licensed, contributions welcome!

## 🙋‍♂️ We Need Your Help!

WingedSwift is an **open-source project** maintained by the community. We're actively looking for contributors! Whether you're:

- 🐛 A bug hunter
- ✨ A feature enthusiast  
- 📝 A documentation lover
- 🧪 A testing expert
- 🌍 A translator

**Your contributions are valuable and welcome!** Check our [Contributing](#-contributing) section to get started.

## Table of Contents

- [Why WingedSwift?](#-why-wingedswift)
- [We Need Your Help!](#️-we-need-your-help)
- [Quick Start](#-quick-start)
- [Getting Started Guide](#-getting-started-from-scratch)
- [Installation](#installation)
  - [Production Use](#swift-package-manager-production)
  - [Local Development](#local-development-for-contributors)
- [Demo](#demo)
- [Usage](#usage)
- [Features](#features)
- [Documentation](#documentation)
- [Contributing](#-contributing)
- [License](#license)

## 🚀 Quick Start

### For Users

```swift
// 1. Add to Package.swift
.package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.0")

// 2. Import and use
import WingedSwift

let page = html {
    Head(children: [Title(content: "My Site")])
    Body(children: [
        H1(content: "Hello, WingedSwift!"),
        P(content: "Creating HTML with Swift is awesome!")
    ])
}

print(page.render(pretty: true))
```

### For Contributors

```bash
# 1. Fork on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/Winged-Swift.git
cd Winged-Swift

# 2. Verify it works
swift build && swift test

# 3. Create a feature branch
git checkout -b feature/my-contribution

# 4. Make changes, test, and submit PR
swift test
# ... make your changes ...
git commit -am "Add: my awesome feature"
git push origin feature/my-contribution
# Then open PR on GitHub
```

See [Contributing](#-contributing) for detailed guidelines.

## 📘 Getting Started from Scratch

### New to WingedSwift? Start here!

**Complete Tutorial**: See [GETTING_STARTED.md](GETTING_STARTED.md) for a step-by-step guide.

**Ready-to-use Template**: Copy and start coding in minutes!

```bash
# 1. Copy starter template
cp -r Examples/StarterTemplate ~/MeuSite
cd ~/MeuSite

# 2. Generate your site
swift run

# 3. Open in browser
open dist/index.html
```

The starter template includes:
- ✅ Complete project structure
- ✅ Beautiful responsive design
- ✅ Example pages (Home, About)
- ✅ CSS styles included
- ✅ Build and dev scripts
- ✅ SEO ready (sitemap.xml)

**What you get:**
```
MyStaticSite/
├── Package.swift              # SPM configuration
├── Sources/
│   ├── main.swift            # Your site generator
│   └── SiteLayout.swift      # Reusable layout
├── Assets/
│   └── css/style.css         # Modern CSS
├── Scripts/
│   ├── build.sh              # Build script
│   ├── dev.sh                # Dev server
│   └── deploy.sh             # Deploy to GitHub Pages
└── dist/                     # Generated site
```

**Learn more:**
- 📖 [Complete Getting Started Guide](GETTING_STARTED.md)
- 📂 [Starter Template](Examples/StarterTemplate/)
- 💡 [Full Examples](EXAMPLE.md)

## Demo

- [https://github.com/micheltlutz/WingedSwiftDemoVapor](https://github.com/micheltlutz/WingedSwiftDemoVapor)

## Installation

### Swift Package Manager (Production)

To add WingedSwift to your project, add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.0")
]
```

And include `WingedSwift` as a dependency in your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "WingedSwift", package: "Winged-Swift")
        ]
    )
]
```

#### Vapor Integration

To include in Vapor project use this line code in `executableTarget`:

```swift
.product(name: "WingedSwift", package: "Winged-Swift")
```

### Local Development (For Contributors)

If you want to contribute or use a local version during development:

#### 1. Fork and Clone

```bash
# Fork the repository on GitHub first, then:
git clone https://github.com/YOUR_USERNAME/Winged-Swift.git
cd Winged-Swift

# Add upstream remote
git remote add upstream https://github.com/micheltlutz/Winged-Swift.git
```

#### 2. Use Local Package in Your Project

In your project's `Package.swift`, reference the local path:

```swift
// Option A: Using local path
dependencies: [
    .package(path: "../Winged-Swift")  // Relative path to local WingedSwift
]

// Option B: Using file URL
dependencies: [
    .package(url: "file:///Users/YOUR_USERNAME/Developer/Winged-Swift", branch: "main")
]
```

#### 3. Development Workflow

```bash
# Create a feature branch
cd Winged-Swift
git checkout -b feature/my-awesome-feature

# Make your changes and test
swift build
swift test

# Commit and push
git add .
git commit -m "Add: my awesome feature"
git push origin feature/my-awesome-feature

# Create Pull Request on GitHub
```

#### 4. Keep Your Fork Updated

```bash
# Fetch latest changes from upstream
git fetch upstream

# Merge upstream changes to your main branch
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

### Xcode Project Setup

You can also open the package directly in Xcode:

```bash
cd Winged-Swift
open Package.swift
```

Or use Xcode's File → Open → select `Package.swift`

### Testing Your Changes in a Real Project

Create a test project to validate your changes:

```bash
# 1. Create a test project directory
mkdir ~/WingedSwiftTest
cd ~/WingedSwiftTest

# 2. Initialize a new Swift package
swift package init --type executable

# 3. Edit Package.swift to use your local WingedSwift
```

Edit `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WingedSwiftTest",
    dependencies: [
        // Use your local fork for testing
        .package(path: "../Winged-Swift")
        // Or use file URL
        // .package(url: "file:///Users/YOUR_USERNAME/Developer/Winged-Swift", branch: "feature/my-feature")
    ],
    targets: [
        .executableTarget(
            name: "WingedSwiftTest",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ]
        )
    ]
)
```

Edit `Sources/main.swift`:

```swift
import WingedSwift

// Test your changes here
let page = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Testing WingedSwift")
    ])
    Body(children: [
        H1(content: "Testing My Changes"),
        P(content: "This is a test of my new feature!")
    ])
}

print(page.render(pretty: true))
```

Run your test:

```bash
swift run
```

This workflow allows you to:
- ✅ Test your changes in a real-world scenario
- ✅ Verify the API is user-friendly
- ✅ Catch integration issues early
- ✅ Ensure documentation matches implementation

## Usage

WingedSwift allows you to build HTML documents using a DSL syntax in Swift. Here are some examples of how to use the library.

### Basic Example

```swift
import WingedSwift

let document = html {
    Head(children: [
        Meta(name: "description", content: "A description of the page"),
        Link(href: "styles.css", rel: "stylesheet")
    ])
    Body(children: [
        Header(children: [
            Nav(children: [
                A(href: "#home", content: "Home"),
                A(href: "#about", content: "About"),
                A(href: "#contact", content: "Contact")
            ])
        ]),
        Main(children: [
            P(content: "Welcome to our website!")
        ]),
        Footer(children: [
            P(content: "© 2024 Company, Inc.")
        ])
    ])
}

print(document.render())
```

### Working with Forms

```swift
let form = Form(attributes: [Attribute(key: "action", value: "/submit")], children: [
    Fieldset(children: [
        Label(for: "name", content: "Name"),
        Input(type: "text", name: "name")
    ]),
    Fieldset(children: [
        Label(for: "message", content: "Message"),
        Textarea(name: "message")
    ]),
    Input(type: "submit", name: "submit", value: "Send")
])

print(form.render())
```

### Code Structure

```swift
let pre = Pre(content: """
This is preformatted text.
It preserves whitespace and line breaks.
""")

print(pre.render())

let code = Code(content: """
let x = 10
print(x)
""")

print(code.render())

let embed = Embed(src: "video.mp4", type: "video/mp4")

print(embed.render())
```

### Pretty Print HTML

WingedSwift now supports pretty printing HTML for better readability during development:

```swift
let page = html {
    Head(children: [Title(content: "My Page")])
    Body(children: [
        H1(content: "Hello World"),
        P(content: "This is a paragraph")
    ])
}

// Compact output (default)
print(page.render())
// Output: <html><head><title>My Page</title></head>...

// Pretty formatted output
print(page.render(pretty: true))
// Output:
// <html>
//   <head>
//     <title>My Page</title>
//   </head>
//   <body>
//     <h1>Hello World</h1>
//     <p>This is a paragraph</p>
//   </body>
// </html>
```

### HTML Security (XSS Protection)

By default, all content is automatically escaped to prevent XSS attacks:

```swift
// User input is automatically escaped
let userInput = "<script>alert('XSS')</script>"
let safe = P(content: userInput)
print(safe.render())
// Output: <p>&lt;script&gt;alert(&#x27;XSS&#x27;)&lt;/script&gt;</p>

// You can disable escaping when you trust the content
let trusted = P(content: "<b>Bold text</b>", escapeContent: false)
print(trusted.render())
// Output: <p><b>Bold text</b></p>
```

### CSS Helpers

Easily manage CSS classes and IDs with fluent API:

```swift
let card = Div()
    .setId("product-card")
    .addClass("card")
    .addClass("shadow-lg")
    .addClasses(["rounded", "p-4"])
    .setStyle("background-color: white;")

// Or use arrays directly
let container = Div()
    .addClasses(["container", "mx-auto", "flex"])
```

### Data Attributes & ARIA Support

Add data attributes and ARIA labels for better accessibility:

```swift
let button = Button()
    .dataAttribute(key: "toggle", value: "modal")
    .dataAttribute(key: "target", value: "#myModal")
    .ariaAttribute(key: "label", value: "Close modal")
    .setRole("button")

let nav = Nav()
    .dataAttributes([
        "component": "navbar",
        "version": "2.0"
    ])
    .ariaAttributes([
        "label": "Main navigation",
        "expanded": "true"
    ])
```

### HTML5 Semantic Tags

Full support for modern HTML5 semantic elements:

```swift
let blog = Article(children: [
    H1(content: "Article Title"),
    Time(datetime: "2024-01-15", content: "January 15, 2024"),
    P(content: "Article content..."),
    Aside(children: [
        H3(content: "Related"),
        P(content: "Related content")
    ])
])

let imageWithCaption = Figure(children: [
    Img(src: "photo.jpg", alt: "Beautiful sunset"),
    Figcaption(content: "A beautiful sunset over the ocean")
])

let highlighted = P(children: [
    HTMLTag("span", content: "This is "),
    Mark(content: "highlighted"),
    HTMLTag("span", content: " text")
])
```

### SEO Helpers

Built-in helpers for Open Graph, Twitter Cards, and common SEO meta tags:

```swift
import WingedSwift

// Complete SEO setup
let seoTags = SEO.complete(
    title: "My Awesome Website",
    description: "The best website ever created",
    image: "https://example.com/og-image.jpg",
    url: "https://example.com",
    keywords: ["swift", "html", "static-site"],
    author: "Your Name",
    twitterSite: "@yoursite",
    twitterCreator: "@yourcreator"
)

let page = html {
    Head(children: [
        Title(content: "My Awesome Website")
    ] + seoTags)
    Body(children: [
        H1(content: "Welcome!")
    ])
}

// Or use individual helpers
let ogTags = SEO.openGraph(
    title: "Page Title",
    description: "Page Description",
    image: "https://example.com/image.jpg",
    url: "https://example.com/page"
)

let twitterTags = SEO.twitterCard(
    title: "Page Title",
    description: "Page Description",
    image: "https://example.com/image.jpg",
    site: "@site",
    creator: "@creator"
)
```

### Static Site Generator

Generate complete static websites with ease:

```swift
import WingedSwift

let generator = StaticSiteGenerator(outputDirectory: "./dist")

// Create your pages
let homePage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Home"),
        Link(href: "css/style.css", rel: "stylesheet")
    ])
    Body(children: [
        H1(content: "Welcome to my site!"),
        P(content: "This is a static site generated with WingedSwift")
    ])
}

let aboutPage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "About"),
        Link(href: "css/style.css", rel: "stylesheet")
    ])
    Body(children: [
        H1(content: "About Us"),
        P(content: "Learn more about our project")
    ])
}

// Generate files
try generator.clean() // Clean output directory
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

// Copy assets
try generator.copyAsset(from: "./assets/css", to: "css")
try generator.copyAsset(from: "./assets/images", to: "images")

// Generate sitemap
let sitemapUrls = [
    SitemapURL(loc: "https://example.com/", changefreq: "daily", priority: 1.0),
    SitemapURL(loc: "https://example.com/about", changefreq: "monthly", priority: 0.8)
]
let sitemap = SitemapGenerator.generate(urls: sitemapUrls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

// Generate RSS feed
let rssGen = RSSGenerator(
    title: "My Blog",
    link: "https://example.com",
    description: "A blog about Swift and web development"
)

let rssItems = [
    RSSItem(
        title: "First Post",
        link: "https://example.com/posts/first",
        description: "My first blog post",
        pubDate: "Mon, 15 Jan 2024 12:00:00 GMT"
    )
]

let rssFeed = rssGen.generate(items: rssItems)
try generator.writeFile(content: rssFeed, to: "feed.xml")
```

### Layout System

Create reusable layouts with the Layout protocol:

```swift
import WingedSwift

class BlogLayout: Layout {
    let siteTitle: String
    let stylesheets: [String]
    
    init(siteTitle: String, stylesheets: [String] = []) {
        self.siteTitle = siteTitle
        self.stylesheets = stylesheets
    }
    
    func render(content: HTMLTag) -> HTMLTag {
        return html {
            Head(children: [
                Meta(charset: "UTF-8"),
                Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
                Title(content: siteTitle)
            ] + stylesheets.map { Link(href: $0, rel: "stylesheet") })
            
            Body(children: [
                Header(children: [
                    H1(content: siteTitle),
                    Nav(children: [
                        A(href: "/", content: "Home"),
                        A(href: "/about", content: "About"),
                        A(href: "/blog", content: "Blog")
                    ])
                ]),
                Main(children: [content]),
                Footer(children: [
                    P(content: "© 2024 My Blog. All rights reserved.")
                ])
            ])
        }
    }
}

// Use the layout
let layout = BlogLayout(
    siteTitle: "My Blog",
    stylesheets: ["css/main.css", "css/blog.css"]
)

let postContent = Article(children: [
    H2(content: "My First Post"),
    P(content: "This is the content of my first post...")
])

let page = layout.render(content: postContent)
try generator.generate(page: page, to: "blog/first-post.html", pretty: true)
```

## Features

- ✅ **Type-Safe DSL**: Leverage Swift's type system for HTML generation
- ✅ **Pretty Print**: Format HTML output for development and debugging
- ✅ **XSS Protection**: Automatic content escaping to prevent attacks
- ✅ **HTML5 Support**: Complete set of modern semantic tags
- ✅ **CSS Helpers**: Fluent API for classes, IDs, and inline styles
- ✅ **Accessibility**: Built-in ARIA and data attribute helpers
- ✅ **SEO Optimized**: Open Graph, Twitter Cards, and meta tag generators
- ✅ **Static Site Generation**: Build complete static websites
- ✅ **Layout System**: Reusable templates with the Layout protocol
- ✅ **Sitemap & RSS**: Automatic sitemap.xml and RSS feed generation
- ✅ **Asset Management**: Easy copying and organizing of assets
- ✅ **Well Tested**: Comprehensive test coverage
- ✅ **Zero Dependencies**: Pure Swift implementation

## Documentation

The complete documentation is available [here soon]().

### Generating the Documentation

To generate the DocC documentation, use the following command in the terminal:

```bash
swift package generate-documentation --target WingedSwift --output-path ./docs
```

```bash
open ./docs/index.html
```

### Preview Documentation

```
swift package --disable-sandbox preview-documentation --target WingedSwift
```

- [http://localhost:8080/documentation/wingedswift](http://localhost:8080/documentation/wingedswift)


## 🤝 Contributing

**WingedSwift is an open-source project and we welcome contributions from the community!** Whether you're fixing bugs, adding features, improving documentation, or sharing ideas, your help is appreciated.

### Ways to Contribute

- 🐛 **Report Bugs**: Open an issue with details about the problem
- ✨ **Suggest Features**: Share your ideas for new functionality
- 📝 **Improve Documentation**: Help make our docs clearer and more comprehensive
- 🔧 **Submit Code**: Fix bugs or implement new features
- 💬 **Help Others**: Answer questions in issues and discussions
- 🌍 **Translate**: Help translate documentation to other languages

### Getting Started with Contributions

#### 1. Set Up Your Development Environment

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Winged-Swift.git
cd Winged-Swift

# Add upstream remote
git remote add upstream https://github.com/micheltlutz/Winged-Swift.git

# Install dependencies and verify everything works
swift build
swift test
```

#### 2. Create a Feature Branch

```bash
# Always create a new branch for your changes
git checkout -b feature/my-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

#### 3. Make Your Changes

- Write clean, readable code following Swift conventions
- Add tests for new functionality
- Update documentation as needed
- Run tests to ensure nothing breaks: `swift test`
- Format your code consistently

#### 4. Test Your Changes

```bash
# Run all tests
swift test

# Build the project
swift build

# Test with your own example project using local path
# (See "Local Development" section above)
```

#### 5. Commit and Push

```bash
# Stage your changes
git add .

# Commit with a clear message
git commit -m "Add: support for new HTML tag XYZ"
# or
git commit -m "Fix: XSS escaping issue in attributes"
# or
git commit -m "Docs: improve SEO helpers examples"

# Push to your fork
git push origin feature/my-feature-name
```

#### 6. Open a Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template with:
   - Description of changes
   - Why the change is needed
   - Any related issues
   - Testing performed
5. Submit and wait for review

### Commit Message Guidelines

Use clear, descriptive commit messages:

- **Add**: `Add: new Feature component`
- **Fix**: `Fix: escape HTML in attribute values`
- **Update**: `Update: SEO helpers with new OG tags`
- **Docs**: `Docs: add examples for Layout system`
- **Test**: `Test: add tests for Pretty Print feature`
- **Refactor**: `Refactor: simplify HTMLTag rendering logic`

### Code Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and single-purpose
- Write tests for new features
- Ensure all tests pass before submitting PR

### Testing

We aim for high test coverage. When adding features:

```bash
# Run tests
swift test

# Run specific test
swift test --filter HTMLEscapeTests

# Generate test coverage (requires additional tools)
swift test --enable-code-coverage
```

### Need Help?

- 📖 Check [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines
- 💬 Open a Discussion for questions
- 📧 Contact: [Michel Lutz](https://micheltlutz.me)
- 🐦 Twitter: [@micheltlutz](https://twitter.com/micheltlutz)

### Recognition

All contributors will be recognized in our repository. Thank you for helping make WingedSwift better! 🙏

### Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## 📊 Project Status

WingedSwift is actively maintained and welcoming contributions!

- ✅ **Current Version**: 1.3.0
- 🚀 **Status**: Active Development
- 📈 **Test Coverage**: High
- 🔄 **Release Cycle**: Regular updates
- 💬 **Community**: Growing

### What's Next?

Check our [Issues](https://github.com/micheltlutz/Winged-Swift/issues) for:
- 🐛 **Good First Issues**: Perfect for newcomers
- ✨ **Feature Requests**: Ideas from the community
- 🆘 **Help Wanted**: Issues where we need your expertise

## 💬 Community & Support

### Get in Touch

- 💭 **Discussions**: [GitHub Discussions](https://github.com/micheltlutz/Winged-Swift/discussions)
- 🐛 **Issues**: [Report bugs or request features](https://github.com/micheltlutz/Winged-Swift/issues)
- 📧 **Email**: Contact via [micheltlutz.me](https://micheltlutz.me)
- 🐦 **Twitter**: [@micheltlutz](https://twitter.com/micheltlutz)

### Stay Updated

- ⭐ **Star** the repository to show support
- 👁️ **Watch** for updates and releases
- 🔔 **Follow** for announcements

### Show Your Support

If WingedSwift is helpful for your project:
- ⭐ Star the repository
- 🐦 Share on social media
- 📝 Write a blog post or tutorial
- 💬 Recommend to friends and colleagues
- 🤝 Contribute code, docs, or ideas

## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
