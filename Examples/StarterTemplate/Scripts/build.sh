#!/bin/bash

echo "🔨 Building site with WingedSwift..."
echo ""

# Limpar build anterior
rm -rf .build 2>/dev/null

# Build e executar
if swift run; then
    echo ""
    echo "✅ Site generated successfully!"
    echo "📂 Output: ./dist"
    echo ""
    echo "To view:"
    echo "  open dist/index.html"
    echo ""
    echo "To serve locally:"
    echo "  winged serve --no-build"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

