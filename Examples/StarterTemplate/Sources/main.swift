import Foundation
import WingedSwift

// === SETUP ===
print("🔨 Generating site...")

let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

// === LAYOUT ===
let layout = SiteLayout(
    siteName: "My Site",
    description: "Site created with WingedSwift"
)

// === PAGES ===

// Home page
let homePage = layout.render(
    title: "Home",
    currentPage: "home",
    content: MainTag(children: [
        Section(children: [
            Div(children: [
                H2(content: "Welcome! 🎉"),
                P(content: "This is a static site generated with WingedSwift."),
                P(content: "Edit Sources/main.swift to customize your site!")
            ])
            .addClass("hero")
        ]),
        
        Section(children: [
            H2(content: "Features"),
            Div(children: [
                createFeatureCard(
                    icon: "⚡️",
                    title: "Fast",
                    description: "HTML generation at build time"
                ),
                createFeatureCard(
                    icon: "🔒",
                    title: "Secure",
                    description: "Automatic XSS protection"
                ),
                createFeatureCard(
                    icon: "🎯",
                    title: "Type-Safe",
                    description: "Leverage the Swift type system"
                )
            ])
            .addClass("features-grid")
        ])
    ])
    .addClass("container")
)

// About page
let aboutPage = layout.render(
    title: "About",
    currentPage: "about",
    content: MainTag(children: [
        Article(children: [
            H2(content: "About This Site"),
            P(content: "This site was created using WingedSwift, a Swift library for HTML generation."),
            P(content: "WingedSwift lets you build static sites in a type-safe, efficient way."),
            
            H3(content: "Technologies"),
            Ul(children: [
                Li(content: "Swift 5.9+"),
                Li(content: "WingedSwift 1.3.0"),
                Li(content: "HTML5 & CSS3")
            ])
        ])
    ])
    .addClass("container")
)

// === GENERATE SITE ===
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

// Copy assets
try generator.copyAsset(from: "./Assets/css", to: "css")
// Uncomment if you have images:
// try generator.copyAsset(from: "./Assets/images", to: "images")

// Generate sitemap
let sitemapUrls = [
    SitemapURL(loc: "https://mysite.com/", priority: 1.0),
    SitemapURL(loc: "https://mysite.com/about.html", priority: 0.8)
]
let sitemap = SitemapGenerator.generate(urls: sitemapUrls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

print("✅ Site generated successfully!")
print("📂 Files available at: ./dist")
print("🌐 To preview: cd dist && python3 -m http.server 8000")

// === HELPERS ===

func createFeatureCard(icon: String, title: String, description: String) -> HTMLTag {
    return Div(children: [
        Div(content: icon, escapeContent: false).addClass("feature-icon"),
        H3(content: title),
        P(content: description)
    ])
    .addClass("feature-card")
}

