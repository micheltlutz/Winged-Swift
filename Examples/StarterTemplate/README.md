# 🚀 WingedSwift Starter Template

Template pronto para criar sites estáticos com WingedSwift.

## 📦 O que está incluído

```
StarterTemplate/
├── Package.swift              # Configuração SPM
├── Sources/
│   ├── main.swift            # Gerador do site
│   └── SiteLayout.swift      # Layout reutilizável
├── Assets/
│   └── css/
│       └── style.css         # Estilos CSS
├── Scripts/
│   ├── build.sh              # Build e gera site
│   ├── dev.sh                # Modo desenvolvimento
│   └── deploy.sh             # Deploy para produção
└── dist/                     # Gerado automaticamente
```

## 🎯 Quick Start

### 1. Copiar Template

```bash
# Copiar este diretório para seu projeto
cp -r Examples/StarterTemplate ~/MeuSite
cd ~/MeuSite
```

### 2. Gerar Site

```bash
# Opção 1: Direto com Swift
swift run

# Opção 2: Usar script
chmod +x Scripts/build.sh
./Scripts/build.sh
```

### 3. Visualizar

```bash
# Abrir no navegador
open dist/index.html

# Ou servir localmente
cd dist
python3 -m http.server 8000
# Acesse: http://localhost:8000
```

## 🛠️ Desenvolvimento

### Modo Watch (Auto-rebuild)

```bash
chmod +x Scripts/dev.sh
./Scripts/dev.sh
```

O script irá:
1. Gerar o site
2. Iniciar servidor local
3. Abrir navegador automaticamente

### Estrutura do Código

#### main.swift
Ponto de entrada. Aqui você:
- Define suas páginas
- Configura o layout
- Gera o site estático

#### SiteLayout.swift
Layout reutilizável com:
- Header com navegação
- Footer
- Meta tags SEO

### Customizar

#### Adicionar Nova Página

Em `Sources/main.swift`:

```swift
let novaPage = layout.render(
    title: "Nova Página",
    currentPage: "nova",
    content: Main(children: [
        H1(content: "Nova Página"),
        P(content: "Conteúdo aqui")
    ]).addClass("container")
)

try generator.generate(page: novaPage, to: "nova.html", pretty: true)
```

#### Modificar Estilos

Edite `Assets/css/style.css`:

```css
/* Suas cores */
:root {
    --primary: #667eea;
    --secondary: #764ba2;
}
```

#### Adicionar Imagens

```bash
# Copiar imagens
cp minha-foto.jpg Assets/images/

# Usar em main.swift
Img(src: "images/minha-foto.jpg", alt: "Minha Foto")
```

## 📊 SEO

O template já inclui:
- ✅ Meta tags básicas
- ✅ Viewport responsive
- ✅ Sitemap.xml gerado automaticamente
- ✅ Estrutura HTML5 semântica

### Adicionar Open Graph

Em `SiteLayout.swift`, adicione ao Head:

```swift
Meta(property: "og:title", content: title),
Meta(property: "og:description", content: description),
Meta(property: "og:image", content: "https://meusite.com/og-image.jpg"),
Meta(property: "og:url", content: "https://meusite.com")
```

## 🚀 Deploy

### GitHub Pages

```bash
chmod +x Scripts/deploy.sh
./Scripts/deploy.sh
```

### Netlify

1. Conecte seu repositório
2. Build command: `swift run`
3. Publish directory: `dist`

### Vercel

```bash
vercel --prod
```

## 📝 Scripts Disponíveis

### build.sh
```bash
./Scripts/build.sh
```
Gera o site em `./dist`

### dev.sh
```bash
./Scripts/dev.sh
```
Modo desenvolvimento com live server

### deploy.sh
```bash
./Scripts/deploy.sh
```
Deploy para GitHub Pages

## 🎨 Personalização Avançada

### Criar Componentes Reutilizáveis

Crie arquivo `Sources/Components.swift`:

```swift
import WingedSwift

func createButton(text: String, href: String, style: String = "primary") -> A {
    return A(href: href, content: text)
        .addClass("btn")
        .addClass("btn-\(style)")
}

func createCard(title: String, content: String, image: String? = nil) -> Div {
    var children: [HTMLTag] = []
    
    if let image = image {
        children.append(Img(src: image, alt: title))
    }
    
    children.append(contentsOf: [
        H3(content: title),
        P(content: content)
    ])
    
    return Div(children: children).addClass("card")
}
```

### Usar Tailwind CSS

1. Adicione CDN no layout:
```swift
Link(href: "https://cdn.tailwindcss.com", rel: "stylesheet")
```

2. Use classes Tailwind:
```swift
Div().addClasses(["flex", "items-center", "justify-between"])
```

## 📚 Exemplos

Ver [EXAMPLE.md](../../EXAMPLE.md) para mais exemplos.

## 🐛 Troubleshooting

**Erro de build**
```bash
rm -rf .build
swift package resolve
swift run
```

**CSS não carrega**
- Verifique se executou: `try generator.copyAsset()`
- Caminho deve ser relativo: `css/style.css`

**Mudanças não aparecem**
```bash
rm -rf dist
swift run
```

## 📦 Dependências

- Swift 5.9+
- WingedSwift 1.3.0+
- Python 3 (para servidor local)

## 💡 Dicas

1. **Use Pretty Print durante desenvolvimento**
   ```swift
   try generator.generate(page: page, to: "index.html", pretty: true)
   ```

2. **Minimize em produção**
   ```swift
   try generator.generate(page: page, to: "index.html", pretty: false)
   ```

3. **Cache de assets**
   - Adicione hash aos nomes: `style.abc123.css`

4. **Otimize imagens**
   - Use formatos modernos (WebP, AVIF)
   - Comprima antes de adicionar

## 🤝 Contribuindo

Melhorias para este template são bem-vindas!

1. Fork o repositório
2. Crie sua feature branch
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

MIT License - use livremente!

## 🔗 Links Úteis

- [WingedSwift](https://github.com/micheltlutz/Winged-Swift)
- [Documentação](../../README.md)
- [Exemplos](../../EXAMPLE.md)
- [Getting Started](../../GETTING_STARTED.md)

---

**Criado com ❤️ usando WingedSwift**

