#!/bin/bash

echo "🚀 Starting development mode..."
echo ""

# Build inicial
echo "🔨 Initial build..."
swift run

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Iniciar servidor
echo ""
echo "🌐 Starting local server..."
echo "📱 Open: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

cd dist && python3 -m http.server 8000

