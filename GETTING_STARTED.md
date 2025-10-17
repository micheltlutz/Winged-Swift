# 🚀 Getting Started - Criando Seu Primeiro Projeto com WingedSwift

Este guia mostra como criar um projeto do zero usando WingedSwift para gerar sites estáticos.

## 📋 Pré-requisitos

- Swift 5.9 ou superior
- Xcode ou linha de comando do Swift instalados

Verifique sua versão:
```bash
swift --version
```

---

## 🎯 Método 1: Projeto Mínimo (Recomendado para Iniciantes)

### Passo 1: Criar Diretório do Projeto

```bash
# Criar diretório do projeto
mkdir MeuSiteSwift
cd MeuSiteSwift
```

### Passo 2: Inicializar Swift Package

```bash
# Criar um executável Swift
swift package init --type executable

# Estrutura criada:
# MeuSiteSwift/
# ├── Package.swift
# ├── Sources/
# │   └── main.swift
# └── Tests/
```

### Passo 3: Configurar Package.swift

Edite o arquivo `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeuSiteSwift",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.3")
    ],
    targets: [
        .executableTarget(
            name: "MeuSiteSwift",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ]
        )
    ]
)
```

### Passo 4: Criar Seu Site (Sources/main.swift)

Substitua o conteúdo de `Sources/main.swift`:

```swift
import Foundation
import WingedSwift

// 1. Configurar gerador de site estático
let generator = StaticSiteGenerator(outputDirectory: "./dist")

// 2. Limpar diretório de saída
try generator.clean()

// 3. Criar página inicial
let homePage = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Meta(name: "viewport", content: "width=device-width, initial-scale=1.0"),
        Title(content: "Meu Primeiro Site com WingedSwift")
    ])
    
    Body(children: [
        Header(children: [
            H1(content: "🎉 Bem-vindo ao WingedSwift!")
        ])
        .addClass("header"),
        
        MainTag(children: [
            Article(children: [
                H2(content: "Sobre este site"),
                P(content: "Este é um site estático gerado com Swift usando WingedSwift!"),
                P(content: "É rápido, type-safe e divertido de criar.")
            ])
        ])
        .addClass("container"),
        
        Footer(children: [
            P(content: "Criado com ❤️ usando WingedSwift")
        ])
        .addClass("footer")
    ])
}

// 4. Gerar HTML
try generator.generate(page: homePage, to: "index.html", pretty: true)

print("✅ Site gerado com sucesso em ./dist/index.html")
```

### Passo 5: Executar e Gerar o Site

```bash
# Buildar e executar
swift run

# Output: ✅ Site gerado com sucesso em ./dist/index.html
```

### Passo 6: Visualizar o Site

```bash
# Abrir no navegador
open dist/index.html

# Ou servir com Python (HTTP server simples)
cd dist
python3 -m http.server 8000
# Acesse: http://localhost:8000
```

---

## 🎨 Método 2: Projeto Completo com CSS

### Estrutura Organizada

```bash
MeuSiteSwift/
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
│   └── images/
└── dist/           # Gerado automaticamente
```

### Setup Completo

#### 1. Package.swift (igual ao Método 1)

#### 2. Assets/css/style.css

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

#### 3. Sources/Layouts/BaseLayout.swift

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
                    P(content: "© 2024 Meu Site. Feito com WingedSwift 🚀")
                ])
                .addClass("footer")
            ])
        }
    }
}
```

#### 4. Sources/Pages/HomePage.swift

```swift
import WingedSwift

struct HomePage {
    static func create(layout: BaseLayout) -> HTMLTag {
        let content = MainTag(children: [
            Article(children: [
                H2(content: "Bem-vindo!"),
                P(content: "Este é um exemplo de site gerado com WingedSwift."),
                P(content: "Você pode criar sites estáticos incríveis usando Swift!")
            ])
        ])
        .addClass("container")
        
        return layout.render(content: content)
    }
}
```

#### 5. Sources/main.swift

```swift
import Foundation
import WingedSwift

// Setup
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

// Layout
let layout = BaseLayout(
    title: "Meu Site Swift",
    description: "Site estático gerado com WingedSwift"
)

// Páginas
let home = HomePage.create(layout: layout)

// Gerar
try generator.generate(page: home, to: "index.html", pretty: true)
try generator.copyAsset(from: "./Assets/css", to: "css")

print("✅ Site gerado com sucesso!")
print("📂 Abra: dist/index.html")
```

#### 6. Executar

```bash
swift run
open dist/index.html
```

---

## 🌐 Método 3: Projeto com Live Server

### Adicionar Script de Desenvolvimento

Crie `Scripts/dev.sh`:

```bash
#!/bin/bash

echo "🔨 Building and generating site..."
swift run

echo "🌐 Starting local server..."
echo "📱 Open: http://localhost:8000"
cd dist && python3 -m http.server 8000
```

Tornar executável:

```bash
chmod +x Scripts/dev.sh
```

Usar:

```bash
./Scripts/dev.sh
```

### Watch Mode (Opcional)

Instalar `fswatch`:

```bash
brew install fswatch
```

Criar `Scripts/watch.sh`:

```bash
#!/bin/bash

echo "👀 Watching for changes..."

fswatch -o Sources/ | while read f; do
    echo "♻️  Changes detected, rebuilding..."
    swift run
    echo "✅ Site regenerated!"
done
```

Usar:

```bash
chmod +x Scripts/watch.sh
./Scripts/watch.sh &
cd dist && python3 -m http.server 8000
```

---

## 📦 Projeto Exemplo Completo - Multi-páginas

### Sources/main.swift

```swift
import Foundation
import WingedSwift

// === CONFIGURAÇÃO ===
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

let layout = BaseLayout(
    title: "Meu Blog Swift",
    description: "Um blog criado com WingedSwift"
)

// === PÁGINAS ===

// Home
let homePage = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "Últimos Posts"),
        Ul(children: [
            Li(children: [A(href: "post1.html", content: "Meu Primeiro Post")]),
            Li(children: [A(href: "post2.html", content: "Aprendendo Swift")]),
            Li(children: [A(href: "about.html", content: "Sobre Mim")])
        ])
    ])
]).addClass("container"))

// Post 1
let post1 = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "Meu Primeiro Post"),
        Time(datetime: "2024-10-16", content: "16 de Outubro, 2024"),
        P(content: "Este é meu primeiro post criado com WingedSwift!"),
        A(href: "index.html", content: "← Voltar")
    ])
]).addClass("container"))

// Sobre
let aboutPage = layout.render(content: MainTag(children: [
    Article(children: [
        H2(content: "Sobre Mim"),
        P(content: "Desenvolvedor Swift apaixonado por criar sites estáticos!"),
        A(href: "index.html", content: "← Voltar")
    ])
]).addClass("container"))

// === GERAR ===
try generator.generate(page: homePage, to: "index.html", pretty: true)
try generator.generate(page: post1, to: "post1.html", pretty: true)
try generator.generate(page: aboutPage, to: "about.html", pretty: true)

// Copiar assets
try generator.copyAsset(from: "./Assets/css", to: "css")

// SEO: Sitemap
let urls = [
    SitemapURL(loc: "https://meusite.com/", priority: 1.0),
    SitemapURL(loc: "https://meusite.com/post1.html", priority: 0.8),
    SitemapURL(loc: "https://meusite.com/about.html", priority: 0.7)
]
let sitemap = SitemapGenerator.generate(urls: urls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")

print("✅ Site completo gerado!")
print("📄 Páginas: index.html, post1.html, about.html")
print("🗺️  Sitemap: sitemap.xml")
```

---

## 🚀 Deploy

### GitHub Pages

```bash
# Gerar site
swift run

# Commit e push
git add dist/
git commit -m "Deploy site"
git subtree push --prefix dist origin gh-pages
```

### Netlify

1. Criar `netlify.toml`:

```toml
[build]
  command = "swift run"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

2. Conectar repositório no Netlify
3. Deploy automático!

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

## 📚 Próximos Passos

1. **Explorar Exemplos**: Veja [EXAMPLE.md](EXAMPLE.md)
2. **Ler Documentação**: [README.md](README.md)
3. **Ver Demo**: [WingedSwiftDemoVapor](https://github.com/micheltlutz/WingedSwiftDemoVapor)
4. **Contribuir**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 💡 Dicas

### Performance

```swift
// Para sites grandes, gere em paralelo
let pages = [(home, "index.html"), (about, "about.html")]

DispatchQueue.concurrentPerform(iterations: pages.count) { index in
    let (page, path) = pages[index]
    try? generator.generate(page: page, to: path, pretty: true)
}
```

### Debug

```swift
// Ver HTML gerado
let page = html { /* ... */ }
print(page.render(pretty: true))
```

### Reutilização

```swift
// Criar componentes reutilizáveis
func createCard(title: String, content: String) -> Div {
    return Div(children: [
        H3(content: title),
        P(content: content)
    ]).addClass("card")
}
```

---

## 🆘 Problemas Comuns

**Erro: "No such module 'WingedSwift'"**
- Execute: `swift package resolve`

**Site não atualiza**
- Delete `.build` e reconstrua: `rm -rf .build && swift run`

**CSS não carrega**
- Verifique o caminho relativo em `Link(href: "css/style.css")`
- Certifique-se de copiar assets: `generator.copyAsset()`

---

## 📞 Suporte

- 📖 Documentação: [README.md](README.md)
- 🐛 Issues: [GitHub Issues](https://github.com/micheltlutz/Winged-Swift/issues)
- 💬 Discussões: [GitHub Discussions](https://github.com/micheltlutz/Winged-Swift/discussions)

**Divirta-se criando sites com Swift! 🚀**

