# GitHub Actions Workflows

Este diretório contém os workflows do GitHub Actions para o projeto WingedSwift.

## 📋 Workflows Disponíveis

### 1. Tests (`tests.yml`)

**Trigger:** Push e Pull Requests para `main` e `develop`

**O que faz:**
- ✅ Roda testes em múltiplos sistemas operacionais (Ubuntu, macOS)
- ✅ Usa Docker container oficial do Swift para Linux
- ✅ Gera relatórios de cobertura de código
- ✅ Envia cobertura para Codecov
- ✅ Executa `Scripts/verify.sh` (o mesmo check que roda localmente)
- ✅ Executa SwiftLint para verificação de código

**Jobs:**
- `test-macos`: Executa testes no macOS 15 (`macos-15`)
- `test-linux`: Executa testes no Ubuntu com Swift Docker (`swift:6.0`)
- `coverage`: Gera e envia cobertura de código (`macos-15`)
- `verify`: Roda `./Scripts/verify.sh` — build, testes, piso macOS 10.13, lint, catálogo de tags, CLI e render de uma página real
- `lint`: Verifica qualidade do código com SwiftLint (`--strict`, não bloqueia o PR)

### 2. Release (`release.yml`)

**Trigger:** Push de tags com formato `v*.*.*` (ex: v1.3.0)

**O que faz:**
- 📦 Cria releases automáticas no GitHub
- 🔢 Confere com `Scripts/check-version.sh` que a tag, o CLI e a biblioteca têm a mesma versão
- 📝 Extrai changelog da versão
- 🏗️ Faz build de release
- ✅ Executa testes antes de publicar
- 📋 Gera notas de release automaticamente

**Como usar:**
```bash
# Criar e fazer push de uma tag
git tag v1.3.0
git push origin v1.3.0

# O workflow criará automaticamente a release
```

### 3. Documentation (`docs.yml`)

**Trigger:** Push para `main` ou execução manual

**O que faz:**
- 📚 Gera documentação DocC
- 🌐 Publica em GitHub Pages
- 🔄 Atualiza automaticamente quando há mudanças

**Acesso:** https://micheltlutz.github.io/Winged-Swift/

## 🔧 Configuração Necessária

### Secrets do GitHub

Para que todos os workflows funcionem corretamente, configure os seguintes secrets no repositório:

1. **CODECOV_TOKEN** (Opcional, mas recomendado)
   - Obtido em https://codecov.io
   - Usado para enviar relatórios de cobertura
   - Path: Settings → Secrets and variables → Actions → New repository secret

2. **GITHUB_TOKEN**
   - Gerado automaticamente pelo GitHub
   - Usado para criar releases e deploy de docs

### GitHub Pages

Para o workflow de documentação funcionar:

1. Vá em Settings → Pages
2. Em "Source", selecione "GitHub Actions"
3. A documentação será publicada automaticamente

## 📊 Status Badges

Adicione estes badges no README.md:

```markdown
![Tests](https://github.com/micheltlutz/Winged-Swift/actions/workflows/tests.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/micheltlutz/Winged-Swift/graph/badge.svg)](https://codecov.io/gh/micheltlutz/Winged-Swift)
```

## 🚀 Workflow de Desenvolvimento

### Para Contribuidores

1. **Fork e Clone** o repositório
2. **Crie uma branch**: `git checkout -b feature/minha-feature`
3. **Faça mudanças** e teste localmente
4. **Push**: `git push origin feature/minha-feature`
5. **Abra PR**: Os workflows de teste rodarão automaticamente
6. **Aguarde aprovação**: Mantenedor revisará e mesclará

### Para Mantenedores

#### Criando uma Release

```bash
# 1. Atualize CHANGELOG.md
vim CHANGELOG.md

# 2. Atualize a versão nos dois lugares (devem ser iguais)
vim Sources/WingedSwift/WingedSwiftVersion.swift
vim Sources/WingedCLI/Winged.swift
./Scripts/check-version.sh v3.0.1

# 3. Commit mudanças
git add .
git commit -m "Change: release 3.0.1"

# 4. Criar tag
git tag v3.0.1

# 5. Push com tags
git push origin main --tags

# 6. O workflow release.yml criará a release automaticamente
```

## 🐛 Troubleshooting

### Testes Falhando

```bash
# Execute localmente primeiro
swift build
swift test

# Verifique logs no GitHub Actions
# Actions → Workflow run → Job details
```

### Coverage não enviando

- Verifique se CODECOV_TOKEN está configurado
- Verifique se o projeto está registrado no Codecov
- Logs em Actions → coverage job

### SwiftLint

```bash
# Instalar SwiftLint localmente
brew install swiftlint

# Executar manualmente
swiftlint lint

# Corrigir automaticamente
swiftlint --fix
```

### Documentação não publicando

- Verifique se GitHub Pages está habilitado
- Verifique permissões do GITHUB_TOKEN
- Source deve ser "GitHub Actions"

## 📝 Customização

### Adicionar nova versão do Swift

O `tests.yml` atual não usa matrix (Linux roda em `swift:6.0`). Para testar várias versões, troque a
imagem fixa por uma matrix:

```yaml
strategy:
  matrix:
    swift-version: ['6.0', '6.1']  # e use image: swift:${{ matrix.swift-version }}
```

### Mudar frequência de build

```yaml
on:
  push:
    branches: [ main ]  # Apenas main
  pull_request:  # Todos os PRs
```

### Adicionar novo OS

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]  # Adicione aqui
```

## 📚 Recursos

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Codecov Documentation](https://docs.codecov.com/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

## 💡 Dicas

1. **Cache Dependencies**: Considere adicionar cache para acelerar builds
2. **Matrix Strategy**: Use para testar múltiplas configurações
3. **Manual Triggers**: Use `workflow_dispatch` para execução manual
4. **Dependabot**: Configure para manter actions atualizadas
5. **Protected Branches**: Configure rules para main branch

## 🤝 Contribuindo

Se você tem sugestões para melhorar os workflows:

1. Abra uma issue descrevendo a melhoria
2. Ou envie um PR com as mudanças propostas
3. Documente as mudanças neste README

---

**Mantido por:** [@micheltlutz](https://github.com/micheltlutz)  
**Última atualização:** Outubro 2026

