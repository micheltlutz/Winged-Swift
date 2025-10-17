import Foundation
import WingedSwift

// === SETUP ===
print("🔨 Gerando site...")

let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

// === LAYOUT ===
let layout = SiteLayout(
    siteName: "Meu Site",
    description: "Site criado com WingedSwift"
)

// === PÁGINAS ===

// Página inicial
let homePage = layout.render(
    title: "Home",
    currentPage: "home",
    content: MainTag(children: [
        Section(children: [
            Div(children: [
                H2(content: "Bem-vindo! 🎉"),
                P(content: "Este é um site estático gerado com WingedSwift."),
                P(content: "Edite Sources/main.swift para personalizar seu site!")
            ])
            .addClass("hero")
        ]),
        
        Section(children: [
            H2(content: "Recursos"),
            Div(children: [
                createFeatureCard(
                    icon: "⚡️",
                    title: "Rápido",
                    description: "Geração de HTML em tempo de compilação"
                ),
                createFeatureCard(
                    icon: "🔒",
                    title: "Seguro",
                    description: "Proteção XSS automática"
                ),
                createFeatureCard(
                    icon: "🎯",
                    title: "Type-Safe",
                    description: "Aproveite o sistema de tipos do Swift"
                )
            ])
            .addClass("features-grid")
        ])
    ])
    .addClass("container")
)

// Página sobre
let aboutPage = layout.render(
    title: "Sobre",
    currentPage: "about",
    content: MainTag(children: [
        Article(children: [
            H2(content: "Sobre Este Site"),
            P(content: "Este site foi criado usando WingedSwift, uma biblioteca Swift para geração de HTML."),
            P(content: "WingedSwift permite criar sites estáticos de forma type-safe e eficiente."),
            
            H3(content: "Tecnologias"),
            Ul(children: [
                Li(content: "Swift 5.9+"),
                Li(content: "WingedSwift 1.3.0"),
                Li(content: "HTML5 & CSS3")
            ])
        ])
    ])
    .addClass("container")
)

// === GERAR SITE ===
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

// Copiar assets
try generator.copyAsset(from: "./Assets/css", to: "css")
// Descomentar se você tiver imagens:
// try generator.copyAsset(from: "./Assets/images", to: "images")

// Gerar sitemap
let sitemapUrls = [
    SitemapURL(loc: "https://meusite.com/", priority: 1.0),
    SitemapURL(loc: "https://meusite.com/about.html", priority: 0.8)
]
let sitemap = SitemapGenerator.generate(urls: sitemapUrls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

print("✅ Site gerado com sucesso!")
print("📂 Arquivos em: ./dist")
print("🌐 Para visualizar: cd dist && python3 -m http.server 8000")

// === HELPERS ===

func createFeatureCard(icon: String, title: String, description: String) -> HTMLTag {
    return Div(children: [
        Div(content: icon, escapeContent: false).addClass("feature-icon"),
        H3(content: title),
        P(content: description)
    ])
    .addClass("feature-card")
}

