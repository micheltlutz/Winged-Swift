#!/bin/bash

echo "🚀 Starting development mode..."
echo ""

# The CLI builds, serves and watches. If you do not have it installed
# (swift build -c release in the Winged-Swift checkout), fall back to any static server.
if command -v winged > /dev/null 2>&1; then
    exec winged serve --watch
fi

echo "ℹ️  winged not found — building once and serving with Python."
swift run || { echo "❌ Build failed!"; exit 1; }

echo ""
echo "🌐 http://localhost:8000  (Ctrl+C to stop)"
cd dist && python3 -m http.server 8000
