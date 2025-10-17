# WingedSwift - Exemplos Completos

Bem-vindo aos exemplos do WingedSwift v1.3.0! Este guia demonstra todas as funcionalidades principais da biblioteca.

## 📑 Índice

- [Exemplo Básico](#exemplo-básico)
- [Pretty Print](#pretty-print)
- [Segurança XSS](#segurança-xss)
- [CSS Helpers](#css-helpers)
- [Data Attributes & ARIA](#data-attributes--aria)
- [Tags HTML5](#tags-html5)
- [SEO Helpers](#seo-helpers)
- [Site Estático Completo](#site-estático-completo)
- [Layout Reutilizável](#layout-reutilizável)
- [Sitemap & RSS](#sitemap--rss)

---

## Exemplo Básico

```swift
import WingedSwift

let document = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
        Title(content: "Minha Página"),
        Link(href: "styles.css", rel: "stylesheet")
    ])
    Body(children: [
        Header(children: [
            H1(content: "Bem-vindo ao WingedSwift!"),
            Nav(children: [
                A(href: "#home", content: "Home"),
                A(href: "#about", content: "Sobre"),
                A(href: "#contact", content: "Contato")
            ])
        ]),
        Main(children: [
            P(content: "Crie sites estáticos incríveis com Swift!")
        ]),
        Footer(children: [
            P(content: "© 2024 Minha Empresa")
        ])
    ])
}

print(document.render())
```

---

## Pretty Print

Gere HTML formatado para facilitar debug e leitura:

```swift
import WingedSwift

let page = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Pretty Print Demo")
    ])
    Body(children: [
        H1(content: "Hello World"),
        P(content: "Este é um parágrafo."),
        Div(children: [
            P(content: "Conteúdo aninhado"),
            P(content: "Mais conteúdo")
        ])
    ])
}

// Saída compacta (padrão)
print(page.render())
// Output: <html><head><meta charset="UTF-8" /><title>Pretty Print Demo</title></head>...

// Saída formatada com indentação
print(page.render(pretty: true))
// Output:
// <html>
//   <head>
//     <meta charset="UTF-8" />
//     <title>Pretty Print Demo</title>
//   </head>
//   <body>
//     <h1>Hello World</h1>
//     <p>Este é um parágrafo.</p>
//     <div>
//       <p>Conteúdo aninhado</p>
//       <p>Mais conteúdo</p>
//     </div>
//   </body>
// </html>
```

---

## Segurança XSS

Proteção automática contra ataques XSS:

```swift
import WingedSwift

// ❌ Entrada potencialmente perigosa
let userInput = "<script>alert('XSS Attack!');</script>"
let userComment = "Olá <b>mundo</b> & 'amigos'"

// ✅ Conteúdo é automaticamente escapado (padrão)
let safe1 = P(content: userInput)
print(safe1.render())
// Output: <p>&lt;script&gt;alert(&#x27;XSS Attack!&#x27;);&lt;/script&gt;</p>

let safe2 = Div(content: userComment)
print(safe2.render())
// Output: <div>Olá &lt;b&gt;mundo&lt;/b&gt; &amp; &#x27;amigos&#x27;</div>

// 🔓 Desabilitar escape quando você confia no conteúdo
let trusted = P(content: "<strong>Negrito</strong>", escapeContent: false)
print(trusted.render())
// Output: <p><strong>Negrito</strong></p>

// 🛡️ Escape manual quando necessário
let manualEscape = HTMLEscape.escape("<script>alert('test')</script>")
print(manualEscape)
// Output: &lt;script&gt;alert(&#x27;test&#x27;)&lt;/script&gt;
```

---

## CSS Helpers

Manipule classes CSS e estilos facilmente:

```swift
import WingedSwift

// Adicionar classes individualmente
let card = Div(content: "Meu Card")
    .setId("product-123")
    .addClass("card")
    .addClass("shadow-lg")
    .addClass("rounded")
    .setStyle("padding: 20px; background: white;")

print(card.render())
// Output: <div id="product-123" class="card shadow-lg rounded" style="padding: 20px; background: white;">Meu Card</div>

// Adicionar múltiplas classes de uma vez
let container = Div(children: [
    H2(content: "Título"),
    P(content: "Conteúdo")
])
.addClasses(["container", "mx-auto", "p-4"])
.setId("main-container")

// Usar com Tailwind CSS
let flexBox = Div(children: [
    Div(content: "Item 1").addClasses(["flex-1", "p-2"]),
    Div(content: "Item 2").addClasses(["flex-1", "p-2"]),
    Div(content: "Item 3").addClasses(["flex-1", "p-2"])
])
.addClasses(["flex", "gap-4", "items-center", "justify-between"])

print(flexBox.render(pretty: true))
```

---

## Data Attributes & ARIA

Acessibilidade e atributos customizados:

```swift
import WingedSwift

// Data attributes para JavaScript
let modal = Div(children: [
    H3(content: "Confirmação"),
    P(content: "Tem certeza?"),
    Button(content: "Confirmar")
        .dataAttribute(key: "action", value: "confirm")
        .dataAttribute(key: "target", value: "modal-123")
])
.dataAttributes([
    "component": "modal",
    "dismissible": "true",
    "backdrop": "static"
])

// ARIA para acessibilidade
let navbar = Nav(children: [
    A(href: "/", content: "Home"),
    A(href: "/products", content: "Produtos"),
    A(href: "/contact", content: "Contato")
])
.ariaAttribute(key: "label", value: "Navegação principal")
.setRole("navigation")

// Botão acessível
let closeButton = Button(content: "×")
    .addClass("btn-close")
    .ariaAttribute(key: "label", value: "Fechar")
    .dataAttribute(key: "dismiss", value: "modal")

// Menu dropdown
let dropdown = Div(children: [
    Button(content: "Menu")
        .setId("dropdownBtn")
        .ariaAttribute(key: "haspopup", value: "true")
        .ariaAttribute(key: "expanded", value: "false"),
    Ul(children: [
        Li(content: "Opção 1"),
        Li(content: "Opção 2")
    ])
    .setRole("menu")
    .ariaAttribute(key: "labelledby", value: "dropdownBtn")
])

print(navbar.render(pretty: true))
```

---

## Tags HTML5

Tags semânticas modernas:

```swift
import WingedSwift

// Blog post com tags semânticas
let blogPost = Article(children: [
    Header(children: [
        H1(content: "Como Criar Sites Estáticos com Swift"),
        Time(
            datetime: "2024-10-16T14:30:00Z",
            content: "16 de Outubro de 2024"
        ).addClass("post-date"),
        P(content: "Por Michel Lutz").addClass("author")
    ]),
    
    Section(children: [
        H2(content: "Introdução"),
        P(content: "WingedSwift é uma biblioteca poderosa para gerar HTML com Swift..."),
        
        Figure(children: [
            Img(src: "images/example.jpg", alt: "Exemplo de código"),
            Figcaption(content: "Figura 1: Estrutura do projeto WingedSwift")
        ]).addClass("figure-center")
    ]),
    
    Aside(children: [
        H3(content: "Artigos Relacionados"),
        Ul(children: [
            Li(children: [A(href: "/posts/swift-server", content: "Swift no Servidor")]),
            Li(children: [A(href: "/posts/html-dsl", content: "DSLs em Swift")])
        ])
    ]).addClass("sidebar"),
    
    Footer(children: [
        P(children: [
            HTMLTag("span", content: "Tags: "),
            Mark(content: "Swift"),
            HTMLTag("span", content: ", "),
            Mark(content: "HTML"),
            HTMLTag("span", content: ", "),
            Mark(content: "Web Development")
        ])
    ])
])
.setId("post-123")
.addClass("blog-post")

print(blogPost.render(pretty: true))

// Todos os headings
let headings = Div(children: [
    H1(content: "Título Principal"),
    H2(content: "Subtítulo"),
    H3(content: "Seção"),
    H4(content: "Subseção"),
    H5(content: "Detalhe"),
    H6(content: "Nota")
])
```

---

## SEO Helpers

Otimização completa para motores de busca:

```swift
import WingedSwift

// 🎯 SEO Completo (tudo em um)
let fullSEO = SEO.complete(
    title: "WingedSwift - DSL HTML em Swift",
    description: "Crie sites estáticos incríveis usando Swift com WingedSwift",
    image: "https://exemplo.com/og-image.jpg",
    url: "https://exemplo.com",
    keywords: ["swift", "html", "dsl", "static site", "web development"],
    author: "Michel Lutz",
    twitterSite: "@wingedswift",
    twitterCreator: "@micheltlutz"
)

let seoPage = html {
    Head(children: [
        Title(content: "WingedSwift - DSL HTML em Swift")
    ] + fullSEO)
    Body(children: [
        H1(content: "Bem-vindo!")
    ])
}

// 📱 Open Graph apenas
let ogTags = SEO.openGraph(
    title: "Título para Redes Sociais",
    description: "Descrição que aparece no Facebook/LinkedIn",
    image: "https://exemplo.com/social-preview.jpg",
    url: "https://exemplo.com/pagina",
    type: "article",
    siteName: "Meu Site"
)

// 🐦 Twitter Card apenas
let twitterTags = SEO.twitterCard(
    title: "Título no Twitter",
    description: "Descrição para Twitter",
    image: "https://exemplo.com/twitter-card.jpg",
    card: "summary_large_image",
    site: "@meusite",
    creator: "@autor"
)

// 📝 Article específico
let articleTags = SEO.openGraphArticle(
    title: "Meu Artigo",
    description: "Descrição do artigo",
    image: "https://exemplo.com/article.jpg",
    url: "https://exemplo.com/article",
    author: "Michel Lutz",
    publishedTime: "2024-10-16T14:30:00Z",
    modifiedTime: "2024-10-16T15:00:00Z"
)

// 🔧 Meta tags comuns
let commonTags = SEO.common(
    title: "Minha Página",
    description: "Descrição da página",
    keywords: ["palavra1", "palavra2"],
    author: "Seu Nome",
    viewport: "width=device-width, initial-scale=1.0",
    robots: "index, follow"
)
```

---

## Site Estático Completo

Exemplo completo de geração de site estático:

```swift
import WingedSwift
import Foundation

// 1️⃣ Configurar o gerador
let generator = StaticSiteGenerator(outputDirectory: "./dist")

// Limpar diretório de saída
try generator.clean()

// 2️⃣ Criar páginas
let homePage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
        Title(content: "Home - Meu Site")
    ] + SEO.complete(
        title: "Meu Site Incrível",
        description: "Um site feito com WingedSwift",
        image: "https://exemplo.com/og.jpg",
        url: "https://exemplo.com"
    ) + [
        Link(href: "css/style.css", rel: "stylesheet")
    ])
    Body(children: [
        Header(children: [
            H1(content: "Meu Site"),
            Nav(children: [
                A(href: "/", content: "Home").addClass("active"),
                A(href: "about.html", content: "Sobre"),
                A(href: "blog.html", content: "Blog"),
                A(href: "contact.html", content: "Contato")
            ])
        ]).addClass("site-header"),
        
        Main(children: [
            Section(children: [
                H2(content: "Bem-vindo!"),
                P(content: "Este site foi gerado com WingedSwift.")
            ]).addClass("hero"),
            
            Section(children: [
                H2(content: "Recursos"),
                Div(children: [
                    Article(children: [
                        H3(content: "Type-Safe"),
                        P(content: "Aproveite o sistema de tipos do Swift")
                    ]).addClass("feature-card"),
                    
                    Article(children: [
                        H3(content: "Rápido"),
                        P(content: "Geração de HTML extremamente rápida")
                    ]).addClass("feature-card"),
                    
                    Article(children: [
                        H3(content: "Seguro"),
                        P(content: "Proteção XSS automática")
                    ]).addClass("feature-card")
                ]).addClass("features-grid")
            ])
        ]).addClass("container"),
        
        Footer(children: [
            P(content: "© 2024 Meu Site. Todos os direitos reservados.")
        ]).addClass("site-footer")
    ])
}

let aboutPage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Sobre - Meu Site"),
        Link(href: "css/style.css", rel: "stylesheet")
    ])
    Body(children: [
        H1(content: "Sobre Nós"),
        P(content: "Somos uma empresa dedicada a criar sites incríveis.")
    ])
}

// 3️⃣ Gerar arquivos HTML
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

// 4️⃣ Copiar assets
try generator.copyAsset(from: "./assets/css", to: "css")
try generator.copyAsset(from: "./assets/js", to: "js")
try generator.copyAsset(from: "./assets/images", to: "images")

print("✅ Site gerado com sucesso em ./dist")
```

---

## Layout Reutilizável

Crie templates reutilizáveis com o protocolo Layout:

```swift
import WingedSwift

// 📐 Definir Layout Base
class SiteLayout: Layout {
    let title: String
    let description: String
    let currentPage: String
    
    init(title: String, description: String, currentPage: String = "") {
        self.title = title
        self.description = description
        self.currentPage = currentPage
    }
    
    func render(content: HTMLTag) -> HTMLTag {
        return html {
            Head(children: [
                Meta(charset: "UTF-8"),
                Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
                Title(content: "\(title) - Meu Site")
            ] + SEO.complete(
                title: title,
                description: description,
                image: "https://exemplo.com/og.jpg",
                url: "https://exemplo.com"
            ) + [
                Link(href: "/css/style.css", rel: "stylesheet"),
                Link(href: "/css/responsive.css", rel: "stylesheet")
            ])
            
            Body(children: [
                // Header
                Header(children: [
                    Div(children: [
                        A(href: "/", children: [
                            Img(src: "/images/logo.png", alt: "Logo")
                                .addClass("logo")
                        ]),
                        Nav(children: [
                            navLink(href: "/", label: "Home", active: currentPage == "home"),
                            navLink(href: "/about", label: "Sobre", active: currentPage == "about"),
                            navLink(href: "/blog", label: "Blog", active: currentPage == "blog"),
                            navLink(href: "/contact", label: "Contato", active: currentPage == "contact")
                        ])
                        .ariaAttribute(key: "label", value: "Navegação principal")
                    ]).addClass("header-content")
                ]).addClass("site-header"),
                
                // Conteúdo principal
                Main(children: [content])
                    .addClass("main-content")
                    .setRole("main"),
                
                // Footer
                Footer(children: [
                    Div(children: [
                        Div(children: [
                            H3(content: "Sobre"),
                            P(content: "Criando sites incríveis com Swift.")
                        ]).addClass("footer-column"),
                        
                        Div(children: [
                            H3(content: "Links"),
                            Ul(children: [
                                Li(children: [A(href: "/privacy", content: "Privacidade")]),
                                Li(children: [A(href: "/terms", content: "Termos")]),
                                Li(children: [A(href: "/sitemap.xml", content: "Sitemap")])
                            ])
                        ]).addClass("footer-column"),
                        
                        Div(children: [
                            H3(content: "Social"),
                            Ul(children: [
                                Li(children: [A(href: "https://twitter.com", content: "Twitter")]),
                                Li(children: [A(href: "https://github.com", content: "GitHub")])
                            ])
                        ]).addClass("footer-column")
                    ]).addClass("footer-grid"),
                    
                    P(content: "© 2024 Meu Site. Todos os direitos reservados.")
                        .addClass("copyright")
                ]).addClass("site-footer")
            ])
        }
    }
    
    private func navLink(href: String, label: String, active: Bool) -> A {
        let link = A(href: href, content: label)
        if active {
            link.addClass("active")
                .ariaAttribute(key: "current", value: "page")
        }
        return link
    }
}

// 🎨 Usar o layout
let layout = SiteLayout(
    title: "Minha Página",
    description: "Uma página incrível",
    currentPage: "home"
)

let pageContent = Div(children: [
    H1(content: "Bem-vindo!"),
    P(content: "Este é o conteúdo da página."),
    Article(children: [
        H2(content: "Artigo"),
        P(content: "Conteúdo do artigo...")
    ])
]).addClass("page-content")

let completePage = layout.render(content: pageContent)

// Gerar
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.generate(page: completePage, to: "index.html", pretty: true)
```

---

## Sitemap & RSS

Gerar sitemap.xml e feed RSS:

```swift
import WingedSwift

let generator = StaticSiteGenerator(outputDirectory: "./dist")

// 🗺️ Gerar Sitemap
let sitemapUrls = [
    SitemapURL(
        loc: "https://exemplo.com/",
        lastmod: "2024-10-16",
        changefreq: "daily",
        priority: 1.0
    ),
    SitemapURL(
        loc: "https://exemplo.com/about",
        lastmod: "2024-10-10",
        changefreq: "monthly",
        priority: 0.8
    ),
    SitemapURL(
        loc: "https://exemplo.com/blog",
        lastmod: "2024-10-16",
        changefreq: "weekly",
        priority: 0.9
    ),
    SitemapURL(
        loc: "https://exemplo.com/contact",
        changefreq: "monthly",
        priority: 0.7
    )
]

let sitemap = SitemapGenerator.generate(urls: sitemapUrls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

// 📡 Gerar RSS Feed
let rssGenerator = RSSGenerator(
    title: "Meu Blog",
    link: "https://exemplo.com",
    description: "Artigos sobre Swift, Web e Tecnologia",
    language: "pt-BR",
    copyright: "© 2024 Meu Blog",
    managingEditor: "editor@exemplo.com (Editor)",
    webmaster: "webmaster@exemplo.com (Webmaster)"
)

let posts = [
    RSSItem(
        title: "Introdução ao WingedSwift",
        link: "https://exemplo.com/posts/introducao-wingedswift",
        description: "Aprenda a criar sites estáticos com Swift",
        pubDate: "Mon, 15 Oct 2024 12:00:00 GMT",
        guid: "https://exemplo.com/posts/introducao-wingedswift",
        author: "autor@exemplo.com (Autor)",
        categories: ["Swift", "Web Development"]
    ),
    RSSItem(
        title: "SEO com WingedSwift",
        link: "https://exemplo.com/posts/seo-wingedswift",
        description: "Otimize seu site para motores de busca",
        pubDate: "Tue, 16 Oct 2024 14:30:00 GMT",
        categories: ["SEO", "Tutorial"]
    )
]

let rssFeed = rssGenerator.generate(items: posts)
try generator.writeFile(content: rssFeed, to: "feed.xml")

print("✅ Sitemap e RSS gerados com sucesso!")
```

---

## 🎉 Conclusão

WingedSwift v1.3.0 oferece todas as ferramentas necessárias para criar sites estáticos profissionais com Swift:

- ✅ Type-safe HTML generation
- ✅ Pretty printing for debugging
- ✅ XSS protection built-in
- ✅ Modern HTML5 semantic tags
- ✅ CSS and styling helpers
- ✅ Accessibility support (ARIA)
- ✅ Complete SEO optimization
- ✅ Static site generation
- ✅ Reusable layouts
- ✅ Sitemap and RSS generation

Para mais informações, consulte o [README](README.md) e a [documentação completa](https://swiftpackageindex.com/micheltlutz/Winged-Swift).
