# 🚀 Publicar WingedSwift v1.3.0 - Comandos Prontos

## ✅ Status Atual

- ✅ Todos os arquivos commitados na branch `develop`
- ✅ Release v1.3.0 já mergeado na `main` 
- ⏳ **Falta apenas**: Push da tag para o GitHub

## 📦 Comandos Para Executar AGORA

### 1. Verificar Branch Main

```bash
cd /Users/michel/Developer/Winged-Swift

# Ver branch atual
git branch

# Se estiver em develop, mudar para main
git checkout main

# Verificar se está atualizado
git log --oneline -5
```

### 2. Push para GitHub (se necessário)

```bash
# Verificar se há commits pendentes
git log origin/main..HEAD --oneline

# Se houver commits, fazer push
git push origin main
```

### 3. Criar e Push Tag v1.3.0

```bash
# Criar tag (EXECUTE ESTE AGORA!)
git tag -a v1.3.0 -m "Release v1.3.0 - Major core improvements for static sites

🎉 Features:
- Pretty Print & XSS Protection  
- HTML5 semantic tags
- CSS & ARIA helpers
- SEO (OpenGraph, Twitter Cards)
- Static site generator
- Layout system
- Sitemap & RSS generators
- Complete starter template

📚 Documentation:
- GETTING_STARTED.md guide
- Examples/StarterTemplate
- Complete CHANGELOG

See CHANGELOG.md for details."

# Verificar tag criada
git tag -l v1.3.0

# Push da tag (EXECUTE ESTE!)
git push origin v1.3.0
```

### 4. Verificar Release Automática

Após pushar a tag, aguarde 1-2 minutos e verifique:

https://github.com/micheltlutz/Winged-Swift/releases

O workflow criará automaticamente a release!

## 🧪 Testar Instalação (Após Push)

Aguarde ~30 segundos após push da tag, então:

```bash
# Ir para seu projeto de teste
cd /Users/michel/Developer/TestSiteWS

# Editar Package.swift para usar versão remota
```

Edite `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/micheltlutz/Winged-Swift.git", from: "1.3.0")
]
```

Teste:

```bash
# Limpar cache
rm -rf .build
rm Package.resolved

# Resolver dependências
swift package resolve

# Build
swift build

# Executar
swift run
```

## 🎯 Resumo: O Que Fazer AGORA

Execute estes 3 comandos:

```bash
# 1. Ir para main (se não estiver)
git checkout main

# 2. Criar tag
git tag -a v1.3.0 -m "Release v1.3.0 - Major core improvements"

# 3. Push tag
git push origin v1.3.0
```

**Pronto!** 🎉

## 📊 Verificações Pós-Release

Após 2-3 minutos do push:

1. ✅ Release criada: https://github.com/micheltlutz/Winged-Swift/releases/tag/v1.3.0
2. ✅ GitHub Actions passou: https://github.com/micheltlutz/Winged-Swift/actions
3. ✅ Instalação funciona: `swift package resolve` no seu projeto teste

## 🐛 Se Der Erro

### "tag already exists"

```bash
# Deletar tag local
git tag -d v1.3.0

# Recriar
git tag -a v1.3.0 -m "Release v1.3.0"
git push origin v1.3.1
```

### "Updates were rejected"

```bash
# Pull primeiro
git pull origin main

# Depois push
git push origin v1.3.0
```

### TestSiteWS não encontra versão

```bash
# Aguardar 1-2 minutos após push da tag
# Limpar cache SPM
rm -rf ~/Library/Caches/org.swift.swiftpm

# No projeto
cd /Users/michel/Developer/TestSiteWS
rm -rf .build Package.resolved
swift package resolve
```

## ⚡ Solução Temporária (Enquanto testa)

Se quiser testar ANTES de fazer push público, use path local:

```swift
// TestSiteWS/Package.swift
dependencies: [
    .package(path: "../Winged-Swift")
]
```

Depois de validar que tudo funciona, publique a tag!

---

**Está tudo pronto! Execute os comandos acima e publique a v1.3.0! 🚀**

