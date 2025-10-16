# 🚀 Release Checklist - WingedSwift v1.3.0

## ✅ Pre-Release (Completado)

- [x] Código implementado e testado
- [x] Testes passando (65 testes ✅)
- [x] Documentação atualizada
- [x] CHANGELOG.md criado
- [x] Versão atualizada em WingedSwift.swift
- [x] Commits locais realizados
- [x] Workflows do GitHub Actions criados

## 📦 Release Steps

### 1. Verificar Status Local

```bash
cd /Users/michel/Developer/Winged-Swift

# Ver commits pendentes
git log origin/main..HEAD --oneline

# Ver status
git status
```

### 2. Push dos Commits

```bash
# Push para main
git push origin main

# Aguardar GitHub Actions rodar
# Acesse: https://github.com/micheltlutz/Winged-Swift/actions
```

### 3. Criar Tag de Release

```bash
# Criar tag local
git tag -a v1.3.0 -m "Release version 1.3.0 - Major core improvements

🎉 New Features:
- Pretty Print HTML formatting
- XSS Protection with automatic escaping
- HTML5 semantic tags (Article, Aside, Figure, Time, Mark, H1-H6)
- CSS Helpers (addClass, setId, addClasses, setStyle)
- Data & ARIA attributes for accessibility
- SEO Helpers (OpenGraph, Twitter Cards, complete setup)
- Static Site Generator for complete websites
- Layout Protocol for reusable templates
- Sitemap Generator (XML)
- RSS Generator (2.0)

🔧 Infrastructure:
- GitHub Actions workflows
- SwiftLint configuration
- Comprehensive test coverage

📚 Documentation:
- Complete GETTING_STARTED.md guide
- Starter Template ready to use
- Updated README with contribution guidelines
- EXAMPLE.md with all features

See CHANGELOG.md for details."

# Verificar tag criada
git tag -l

# Push da tag
git push origin v1.3.0
```

### 4. Verificar Release Automática

O workflow `release.yml` criará automaticamente a release no GitHub:

1. Acesse: https://github.com/micheltlutz/Winged-Swift/releases
2. Verifique se a release v1.3.0 foi criada
3. Edite se necessário para adicionar informações

### 5. Configurar Codecov (Opcional)

Se ainda não fez:

1. Acesse: https://codecov.io
2. Login com GitHub
3. Adicione o repositório Winged-Swift
4. Copie o token
5. Adicione nos secrets:
   - Settings → Secrets and variables → Actions
   - New repository secret
   - Nome: `CODECOV_TOKEN`
   - Valor: [seu token]

### 6. Habilitar GitHub Pages (Opcional)

Para documentação automática:

1. Settings → Pages
2. Source: **GitHub Actions**
3. Save

Documentação será publicada em:
https://micheltlutz.github.io/Winged-Swift/

### 7. Testar Instalação

Após o push da tag, teste a instalação:

```bash
# Criar projeto teste
cd ~
mkdir TestWingedSwift
cd TestWingedSwift
swift package init --type executable
```

Edite `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TestWingedSwift",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "TestWingedSwift",
            dependencies: ["WingedSwift"]
        )
    ]
)
```

Teste:

```bash
swift build
# Deve baixar e compilar WingedSwift v1.3.0
```

### 8. Anunciar Release

Depois que tudo estiver funcionando:

#### Twitter/X
```
🚀 WingedSwift v1.3.0 is out!

✨ Major update for static site generation in Swift:
- Pretty Print & XSS Protection
- HTML5 semantic tags
- SEO helpers (OG, Twitter Cards)
- Static site generator
- Layout system
- Complete starter template

https://github.com/micheltlutz/Winged-Swift

#Swift #WebDev #OpenSource
```

#### Dev.to / Medium (Opcional)
Escrever post sobre:
- O que é WingedSwift
- Novidades da v1.3.0
- Como criar seu primeiro site estático
- Por que Swift para HTML

#### Reddit (Opcional)
- r/swift
- r/webdev
- r/programming

### 9. Atualizar Swift Package Index

O Swift Package Index será atualizado automaticamente, mas você pode:

1. Verificar em: https://swiftpackageindex.com/micheltlutz/Winged-Swift
2. Aguardar indexação (pode levar algumas horas)

## 🔄 Post-Release

### Verificar Issues

Após release, monitore:
- https://github.com/micheltlutz/Winged-Swift/issues
- Possíveis bugs reportados
- Perguntas de usuários

### Preparar Próxima Versão

Criar branch para desenvolvimento:

```bash
git checkout -b develop
git push origin develop
```

Atualizar versão para próximo ciclo:

```swift
// WingedSwift.swift
case VERSION = "1.4.0-dev"
```

## 📊 Checklist Final

Antes de considerar release completo:

- [ ] Commits pushed para main
- [ ] Tag v1.3.0 criada e pushed
- [ ] Release aparece no GitHub
- [ ] Testes passando no CI
- [ ] Coverage report no Codecov (opcional)
- [ ] GitHub Pages funcionando (opcional)
- [ ] Instalação via SPM funcionando
- [ ] Swift Package Index atualizado
- [ ] Anúncio nas redes sociais (opcional)

## 🐛 Troubleshooting

### Tag já existe

```bash
# Deletar tag local
git tag -d v1.3.0

# Deletar tag remota
git push origin :refs/tags/v1.3.0

# Recriar
git tag -a v1.3.0 -m "..."
git push origin v1.3.0
```

### CI falhando

1. Ver logs: Actions → workflow → job details
2. Corrigir problema
3. Fazer novo commit
4. Push
5. Aguardar CI passar

### Release não criada automaticamente

1. Verificar se workflow `release.yml` existe
2. Verificar logs do workflow
3. Criar release manualmente se necessário

### Instalação falhando

```bash
# Limpar cache do SPM
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build

# Tentar novamente
swift package resolve
swift build
```

## 📞 Ajuda

Se encontrar problemas:

1. Verifique logs do GitHub Actions
2. Abra issue no repositório
3. Consulte documentação do Swift Package Manager

---

**Boa sorte com a release! 🚀**

