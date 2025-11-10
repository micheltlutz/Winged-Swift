# ⚡ Quick Start - 3 Comandos para Seu Primeiro Site

## 🚀 Maneira Mais Rápida

### Método 1: Copiar Template (RECOMENDADO)

```bash
# 1. Copiar template
cp -r Examples/StarterTemplate ~/MeuSite
cd ~/MeuSite

# 2. Gerar site
swift run

# 3. Abrir no navegador
open dist/index.html
```

**Pronto!** Você tem um site funcionando! 🎉

---

## 📝 Método 2: Criar do Zero (5 minutos)

### Passo 1: Criar projeto

```bash
mkdir ~/MeuSite
cd ~/MeuSite
swift package init --type executable
```

### Passo 2: Editar Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeuSite",
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.3")
    ],
    targets: [
        .executableTarget(
            name: "MeuSite",
            dependencies: [
                .product(name: "WingedSwift", package: "Winged-Swift")
            ]
        )
    ]
)
```

### Passo 3: Editar Sources/main.swift

```swift
import Foundation
import WingedSwift

// Setup
let generator = StaticSiteGenerator(outputDirectory: "./dist")
try generator.clean()

// Criar página
let page = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Meu Site")
    ])
    Body(children: [
        H1(content: "Olá, WingedSwift! 🚀"),
        P(content: "Meu primeiro site estático com Swift!")
    ])
}

// Gerar
try generator.generate(page: page, to: "index.html", pretty: true)
print("✅ Site gerado em dist/index.html")
```

### Passo 4: Executar

```bash
swift run
open dist/index.html
```

---

## 🎨 Adicionar CSS (Opcional)

### 1. Criar arquivo CSS

```bash
mkdir -p Assets/css
```

Criar `Assets/css/style.css`:

```css
body {
    font-family: -apple-system, sans-serif;
    max-width: 800px;
    margin: 50px auto;
    padding: 20px;
}

h1 { color: #667eea; }
```

### 2. Usar no HTML

```swift
let page = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Meu Site"),
        Link(href: "css/style.css", rel: "stylesheet") // 👈 Adicionar
    ])
    Body(children: [
        H1(content: "Olá, WingedSwift! 🚀"),
        P(content: "Agora com estilo!")
    ])
}

// Copiar CSS
try generator.copyAsset(from: "./Assets/css", to: "css")
```

---

## 🌐 Ver no Navegador com Servidor Local

```bash
# Opção 1: Python
cd dist
python3 -m http.server 8000
# Acesse: http://localhost:8000

# Opção 2: PHP
cd dist
php -S localhost:8000

# Opção 3: npx (Node.js)
cd dist
npx serve
```

---

## 📦 O Que Você Aprende

### Estrutura Mínima

```
MeuSite/
├── Package.swift          # Dependências SPM
├── Sources/
│   └── main.swift        # Seu código
├── Assets/               # Opcional
│   └── css/
│       └── style.css
└── dist/                 # Gerado automaticamente
    ├── index.html
    └── css/
        └── style.css
```

### Comandos Importantes

```bash
# Build
swift build

# Executar (gera site)
swift run

# Limpar
rm -rf .build dist

# Resolver dependências
swift package resolve
```

---

## 🎯 Próximos Passos

1. ✅ **Ver Exemplos**: [EXAMPLE.md](EXAMPLE.md)
2. ✅ **Ler Guia Completo**: [GETTING_STARTED.md](GETTING_STARTED.md)
3. ✅ **Explorar Template**: [StarterTemplate](Examples/StarterTemplate/)
4. ✅ **Adicionar SEO**: [README.md#seo-helpers](README.md)
5. ✅ **Publicar**: GitHub Pages, Netlify, Vercel

---

## 💡 Dicas Rápidas

### Múltiplas Páginas

```swift
let home = html { /* ... */ }
let about = html { /* ... */ }
let contact = html { /* ... */ }

try generator.generate(page: home, to: "index.html")
try generator.generate(page: about, to: "about.html")
try generator.generate(page: contact, to: "contact.html")
```

### SEO Fácil

```swift
let seoTags = SEO.complete(
    title: "Meu Site",
    description: "Site incrível",
    image: "https://meusite.com/og.jpg",
    url: "https://meusite.com"
)

Head(children: [Title(content: "Meu Site")] + seoTags)
```

### Sitemap

```swift
let urls = [
    SitemapURL(loc: "https://meusite.com/", priority: 1.0),
    SitemapURL(loc: "https://meusite.com/about", priority: 0.8)
]
let sitemap = SitemapGenerator.generate(urls: urls)
try generator.writeFile(content: sitemap, to: "sitemap.xml")
```

---

## 🆘 Problemas?

**"No such module 'WingedSwift'"**
```bash
swift package resolve
swift build
```

**Site não atualiza**
```bash
rm -rf .build dist
swift run
```

**CSS não carrega**
```bash
# Certifique-se de copiar assets
try generator.copyAsset(from: "./Assets/css", to: "css")
```

---

## 📞 Suporte

- 📖 [Documentação Completa](README.md)
- 💡 [Exemplos](EXAMPLE.md)
- 🐛 [Issues](https://github.com/micheltlutz/Winged-Swift/issues)

**Divirta-se! 🚀**

