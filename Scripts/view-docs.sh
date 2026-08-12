#!/bin/bash

# Script para visualizar a documentação DocC localmente

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"

echo "📚 WingedSwift - Visualização de Documentação"
echo "=============================================="
echo ""

# Verificar se a documentação existe
if [ ! -f "$DOCS_DIR/index.html" ]; then
    echo "⚠️  Documentação não encontrada. Gerando..."
    echo ""
    cd "$PROJECT_ROOT"
    swift package --allow-writing-to-directory ./docs \
        generate-documentation --target WingedSwift \
        --output-path ./docs \
        --transform-for-static-hosting \
        --hosting-base-path /Winged-Swift
    echo ""
fi

# Criar estrutura temporária para servir corretamente
TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

# Criar estrutura que mapeia /Winged-Swift para docs
echo "📁 Preparando estrutura de diretórios..."
mkdir -p "$TEMP_DIR/Winged-Swift"

# Copiar todo o conteúdo de docs para a estrutura temporária
if command -v rsync &> /dev/null; then
    rsync -a "$DOCS_DIR/" "$TEMP_DIR/Winged-Swift/" --exclude='.DS_Store'
else
    # Fallback para cp - método mais compatível
    (cd "$DOCS_DIR" && find . -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -exec cp -R {} "$TEMP_DIR/Winged-Swift/" \;)
fi

if [ ! -f "$TEMP_DIR/Winged-Swift/index.html" ]; then
    echo "❌ Erro ao preparar estrutura. Use o preview mode do DocC:"
    echo "   swift package --disable-sandbox preview-documentation --target WingedSwift"
    exit 1
fi

# Verificar se Python está disponível
if command -v python3 &> /dev/null; then
    echo "✅ Iniciando servidor HTTP local..."
    echo ""
    echo "📖 Acesse a documentação em:"
    echo "   http://localhost:8000/Winged-Swift/documentation/wingedswift/"
    echo ""
    echo "⚠️  Pressione Ctrl+C para parar o servidor"
    echo ""
    cd "$TEMP_DIR"
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "✅ Iniciando servidor HTTP local..."
    echo ""
    echo "📖 Acesse a documentação em:"
    echo "   http://localhost:8000/Winged-Swift/documentation/wingedswift/"
    echo ""
    echo "⚠️  Pressione Ctrl+C para parar o servidor"
    echo ""
    cd "$TEMP_DIR"
    python -m SimpleHTTPServer 8000
else
    echo "❌ Python não encontrado."
    echo ""
    echo "💡 Recomendamos usar o preview mode do DocC (mais simples):"
    echo "   swift package --disable-sandbox preview-documentation --target WingedSwift"
    echo ""
    echo "💡 Alternativas:"
    echo "   1. Instale Python: https://www.python.org/downloads/"
    echo "   2. Use Node.js http-server:"
    echo "      cd docs && npx http-server -p 8000"
    exit 1
fi

