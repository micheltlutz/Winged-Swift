# 🚀 WingedSwift Starter Template

Ready-to-use template to build static sites with WingedSwift.

## 📦 What's Included

```
StarterTemplate/
├── Package.swift              # SPM configuration
├── Sources/
│   ├── main.swift             # Site generator
│   └── SiteLayout.swift       # Reusable layout
├── Assets/
│   └── css/
│       └── style.css          # CSS styles
├── Scripts/
│   ├── build.sh               # Builds and generates the site
│   ├── dev.sh                 # Development mode
│   └── deploy.sh              # Production deploy
└── dist/                      # Generated automatically
```

## 🎯 Quick Start

### 1. Copy the Template

```bash
# Copy this directory into your project
cp -r Examples/StarterTemplate ~/MySite
cd ~/MySite
```

### 2. Generate the Site

```bash
# Option 1: Run directly with Swift
swift run

# Option 2: Use the script
chmod +x Scripts/build.sh
./Scripts/build.sh
```

### 3. Preview

```bash
# Open in the browser
open dist/index.html

# Or serve locally
cd dist
python3 -m http.server 8000
# Visit: http://localhost:8000
```

## 🛠️ Development

### Watch Mode (Auto-rebuild)

```bash
chmod +x Scripts/dev.sh
./Scripts/dev.sh
```

The script will:
1. Build the site
2. Start a local server
3. Open the browser automatically

### Code Structure

#### `main.swift`
Entry point where you:
- Define your pages
- Configure the layout
- Generate the static site

#### `SiteLayout.swift`
Reusable layout with:
- Header + navigation
- Footer
- SEO meta tags

### Customize

#### Add a New Page

In `Sources/main.swift`:

```swift
let newPage = layout.render(
    title: "New Page",
    currentPage: "new",
    content: Main(children: [
        H1(content: "New Page"),
        P(content: "Content goes here")
    ]).addClass("container")
)

try generator.generate(page: newPage, to: "new.html", pretty: true)
```

#### Modify Styles

Edit `Assets/css/style.css`:

```css
/* Your color palette */
:root {
    --primary: #667eea;
    --secondary: #764ba2;
}
```

#### Add Images

```bash
# Copy images
cp my-photo.jpg Assets/images/

# Use in main.swift
Img(src: "images/my-photo.jpg", alt: "My Photo")
```

## 📊 SEO

The template already includes:
- ✅ Essential meta tags
- ✅ Responsive viewport
- ✅ Automatic sitemap.xml generation
- ✅ Semantic HTML5 structure

### Add Open Graph Tags

In `SiteLayout.swift`, inside the `Head`:

```swift
Meta(property: "og:title", content: title),
Meta(property: "og:description", content: description),
Meta(property: "og:image", content: "https://mysite.com/og-image.jpg"),
Meta(property: "og:url", content: "https://mysite.com")
```

## 🚀 Deploy

### GitHub Pages

```bash
chmod +x Scripts/deploy.sh
./Scripts/deploy.sh
```

### Netlify

1. Connect your repository
2. Build command: `swift run`
3. Publish directory: `dist`

### Vercel

```bash
vercel --prod
```

## 📝 Available Scripts

### `build.sh`
```bash
./Scripts/build.sh
```
Generates the site into `./dist`

### `dev.sh`
```bash
./Scripts/dev.sh
```
Development mode with live server

### `deploy.sh`
```bash
./Scripts/deploy.sh
```
Deploy to GitHub Pages

## 🎨 Advanced Customization

### Create Reusable Components

Create `Sources/Components.swift`:

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

### Use Tailwind CSS

1. Add the CDN to the layout:
```swift
Link(href: "https://cdn.tailwindcss.com", rel: "stylesheet")
```

2. Use Tailwind utility classes:
```swift
Div().addClasses(["flex", "items-center", "justify-between"])
```

## 📚 Examples

See [EXAMPLE.md](../../EXAMPLE.md) for more samples.

## 🐛 Troubleshooting

**Build error**
```bash
rm -rf .build
swift package resolve
swift run
```

**CSS not loading**
- Make sure you ran: `try generator.copyAsset()`
- Paths must be relative: `css/style.css`

**Changes not showing up**
```bash
rm -rf dist
swift run
```

## 📦 Requirements

- Swift 5.9+
- WingedSwift 1.3.0+
- Python 3 (local server)

## 💡 Tips

1. **Use pretty print during development**
   ```swift
   try generator.generate(page: page, to: "index.html", pretty: true)
   ```

2. **Minify for production**
   ```swift
   try generator.generate(page: page, to: "index.html", pretty: false)
   ```

3. **Cache-bust assets**
   - Add hashes to filenames: `style.abc123.css`

4. **Optimize images**
   - Prefer modern formats (WebP, AVIF)
   - Compress before adding

## 🤝 Contributing

Improvements to this template are welcome!

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push the branch
5. Open a Pull Request

## 📄 License

MIT License — use freely!

## 🔗 Useful Links

- [WingedSwift](https://github.com/micheltlutz/Winged-Swift)
- [Documentation](../../README.md)
- [Examples](../../EXAMPLE.md)
- [Getting Started](../../GETTING_STARTED.md)

---

**Built with ❤️ using WingedSwift**

