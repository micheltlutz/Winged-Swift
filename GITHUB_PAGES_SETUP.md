# 📚 Configurar GitHub Pages para Documentação DocC

Este guia explica como configurar o GitHub Pages para publicar a documentação DocC do WingedSwift automaticamente.

## ✅ Pré-requisitos

- ✅ Workflow `.github/workflows/docs.yml` já configurado
- ✅ Permissões corretas no workflow (já configuradas)
- ⚠️ **Ação necessária:** Configurar GitHub Pages nas configurações do repositório

## 🚀 Passo a Passo

### 1. Ativar GitHub Pages no Repositório

1. Vá para o repositório no GitHub: https://github.com/micheltlutz/Winged-Swift

2. Clique em **Settings** (Configurações)

3. No menu lateral, clique em **Pages**

4. Em **Source**, selecione:
   - **Source:** `GitHub Actions` (não selecione branch!)
   - Isso permite que o workflow publique automaticamente

5. **Salve** as configurações

### 2. Fazer Push das Alterações

Depois de configurar o GitHub Pages, faça push das alterações para a branch `main`:

```bash
# Adicionar alterações
git add .github/workflows/docs.yml README.md Scripts/view-docs.sh

# Commit
git commit -m "feat: configurar publicação automática de documentação no GitHub Pages"

# Push para main
git push origin main
```

### 3. Verificar o Workflow

1. Vá para **Actions** no GitHub
2. Clique no workflow **Documentation**
3. Verifique se está rodando automaticamente
4. Aguarde a conclusão (pode levar alguns minutos)

### 4. Acessar a Documentação

Após o workflow completar com sucesso, a documentação estará disponível em:

**🌐 URL:** https://micheltlutz.github.io/Winged-Swift/

Ou especificamente:
- **Documentação Principal:** https://micheltlutz.github.io/Winged-Swift/documentation/wingedswift/
- **Download:** https://micheltlutz.github.io/Winged-Swift/downloads/

## 🔄 Atualização Automática

A documentação será **atualizada automaticamente** sempre que:

- ✅ Um push for feito para a branch `main`
- ✅ Você executar o workflow manualmente (Actions → Documentation → Run workflow)

## 🛠️ Executar Manualmente

Se quiser gerar a documentação manualmente sem fazer push:

1. Vá para **Actions** no GitHub
2. Clique em **Documentation**
3. Clique em **Run workflow**
4. Selecione a branch `main`
5. Clique em **Run workflow**

## 📝 Verificar Status

### Verificar se o GitHub Pages está ativo:

1. Vá em **Settings → Pages**
2. Você deve ver:
   - ✅ **Status:** "Your site is live at..."
   - ✅ **Source:** "GitHub Actions"

### Verificar se o workflow está funcionando:

1. Vá em **Actions → Documentation**
2. Verifique se há execuções recentes
3. Clique em uma execução para ver os logs

## 🐛 Problemas Comuns

### Erro: "Resource not accessible by integration"

**Solução:** Verifique se as permissões no workflow estão corretas:
```yaml
permissions:
  contents: write
  pages: write
  id-token: write
```

### Workflow não está rodando

**Solução:** 
1. Verifique se o arquivo `.github/workflows/docs.yml` está na branch `main`
2. Verifique se o GitHub Pages está configurado para usar "GitHub Actions"

### Documentação não aparece

**Solução:**
1. Aguarde alguns minutos (pode levar até 5 minutos)
2. Verifique se o workflow completou com sucesso
3. Limpe o cache do navegador (Ctrl+Shift+R ou Cmd+Shift+R)
4. Verifique a URL: deve ser `https://micheltlutz.github.io/Winged-Swift/`

### Página em branco

**Solução:** 
- Verifique se o `hosting-base-path` está correto: `/Winged-Swift`
- A URL deve ser: `https://micheltlutz.github.io/Winged-Swift/documentation/wingedswift/`

## 📊 Estrutura da Documentação Publicada

```
https://micheltlutz.github.io/Winged-Swift/
├── index.html                    # Página inicial
├── documentation/
│   └── wingedswift/             # Documentação principal
│       ├── index.html
│       ├── htmltag/
│       ├── staticsitegenerator/
│       └── ...
├── downloads/                    # Downloads
├── css/                         # Estilos
├── js/                          # JavaScript
└── images/                      # Imagens
```

## 🔗 Links Úteis

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift DocC Documentation](https://www.swift.org/documentation/docc/)

## ✅ Checklist Final

- [ ] GitHub Pages ativado (Settings → Pages → Source: GitHub Actions)
- [ ] Workflow `docs.yml` presente na branch `main`
- [ ] Permissões corretas no workflow
- [ ] Push feito para `main`
- [ ] Workflow executado com sucesso
- [ ] Documentação acessível em https://micheltlutz.github.io/Winged-Swift/

---

**Depois de configurar, a documentação será atualizada automaticamente a cada push para `main`! 🚀**

