#!/bin/bash

echo "🚀 Deploying to GitHub Pages..."
echo ""

# Build
echo "🔨 Building site..."
swift run

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Verificar se é um repositório git
if [ ! -d .git ]; then
    echo "⚠️  Not a git repository. Initialize with:"
    echo "  git init"
    echo "  git remote add origin YOUR_REPO_URL"
    exit 1
fi

# Deploy
echo ""
echo "📤 Pushing to gh-pages branch..."

git add dist -f
git commit -m "Deploy: $(date +'%Y-%m-%d %H:%M:%S')"
git subtree push --prefix dist origin gh-pages

echo ""
echo "✅ Deployed!"
echo "🌐 Your site will be available at:"
echo "   https://YOUR_USERNAME.github.io/YOUR_REPO/"

