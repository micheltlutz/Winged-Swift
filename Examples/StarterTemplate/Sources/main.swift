import Foundation
import WingedSwift

// === SETUP ===
print("🔨 Generating site...")

let outputDirectory = CommandLine.arguments.dropFirst().first ?? "./dist"
let generator = StaticSiteGenerator(outputDirectory: outputDirectory)
try generator.clean()

let layout = SiteLayout(
    siteName: "My Site",
    description: "Site created with WingedSwift"
)

// === COMPONENTS ===

struct Feature {
    let icon: String
    let title: String
    let description: String
}

let features = [
    Feature(icon: "⚡️", title: "Fast", description: "HTML generation at build time"),
    Feature(icon: "🔒", title: "Secure", description: "Automatic XSS protection"),
    Feature(icon: "🎯", title: "Type-Safe", description: "Leverage the Swift type system")
]

func featureCard(_ feature: Feature) -> HTMLTag {
    Div {
        Div(content: feature.icon).addClass("feature-icon")
        H3(content: feature.title)
        P(content: feature.description)
    }
    .addClass("feature-card")
}

// === PAGES ===

let homePage = layout.page(title: "Home", currentPage: "home") {
    Section {
        Div {
            H2(content: "Welcome! 🎉")
            P(content: "This is a static site generated with WingedSwift.")
            P(content: "Edit Sources/main.swift to customize your site!")
        }
        .addClass("hero")
    }

    Section {
        H2(content: "Features")
        Div {
            for feature in features {
                featureCard(feature)
            }
        }
        .addClass("features-grid")
    }
}

let aboutPage = layout.page(title: "About", currentPage: "about") {
    Section {
        H2(content: "About this site")
        P(content: "Written in Swift, rendered to static HTML — no runtime, no server.")
        Ul {
            for item in ["Type-safe markup", "Escaped by default", "SEO helpers included"] {
                Li(content: item)
            }
        }
    }
}

// === OUTPUT ===

try generator.generateMultiple(documents: [
    (document: homePage, path: "index.html"),
    (document: aboutPage, path: "about.html")
])

try generator.copyAsset(from: "./Assets/css", to: "css")

try generator.writeFile(
    content: SitemapGenerator.generate(urls: [
        SitemapURL(loc: "https://example.com/", changefreq: "weekly", priority: 1.0),
        SitemapURL(loc: "https://example.com/about.html", changefreq: "monthly", priority: 0.6)
    ]),
    to: "sitemap.xml"
)

try generator.writeFile(content: "User-agent: *\nAllow: /", to: "robots.txt")

print("✅ Site generated successfully!")
print("📂 Files available at: \(outputDirectory)")
print("🌐 To preview: winged serve --no-build")
