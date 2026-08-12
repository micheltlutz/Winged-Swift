#!/bin/bash
#
# One command to check a change to WingedSwift: build, test, lint, catalog freshness and a
# real end-to-end render. Run this before opening a pull request — and if you are a coding
# agent, run it before reporting that you are done.
#
# Usage: ./Scripts/verify.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILURES=0

step() { printf "\n\033[0;36m▶ %s\033[0m\n" "$1"; }
ok()   { printf "\033[0;32m✅ %s\033[0m\n" "$1"; }
fail() { printf "\033[0;31m❌ %s\033[0m\n" "$1"; FAILURES=$((FAILURES + 1)); }

step "swift build"
if swift build 2>&1 | tail -5; then ok "build"; else fail "build"; fi

step "swift test"
if swift test 2>&1 | tail -5; then ok "tests"; else fail "tests"; fi

step "swiftlint"
if command -v swiftlint > /dev/null 2>&1; then
    if swiftlint lint --strict --quiet; then ok "lint"; else fail "lint"; fi
else
    printf "\033[1;33m⚠️  swiftlint not installed (brew install swiftlint) — skipped\033[0m\n"
fi

step "tag catalog freshness"
if ./Scripts/generate-tag-catalog.sh --check; then ok "catalog"; else fail "catalog"; fi

step "end-to-end render"
RENDER_DIR="$(mktemp -d)"
trap 'rm -rf "$RENDER_DIR"' EXIT
mkdir -p "$RENDER_DIR/Sources/RenderSmokeTest"

cat > "$RENDER_DIR/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RenderSmokeTest",
    dependencies: [.package(path: "$ROOT")],
    targets: [
        .executableTarget(
            name: "RenderSmokeTest",
            dependencies: [.product(name: "WingedSwift", package: "Winged-Swift")]
        )
    ]
)
EOF

cat > "$RENDER_DIR/Sources/RenderSmokeTest/main.swift" <<'EOF'
import WingedSwift

let page = html {
    Head(children: [
        Meta(charset: "UTF-8"),
        Title(content: "Smoke test")
    ])
    Body(children: [
        MainTag(children: [
            H1(content: "It renders"),
            Table(children: [
                Thead(children: [Tr(children: [Th(content: "Tag")])]),
                Tbody(children: [Tr(children: [Td(content: "<ok>")])])
            ]),
            Details(children: [Summary(content: "More"), P(content: "Hidden")])
        ])
    ])
}

let generator = StaticSiteGenerator(outputDirectory: CommandLine.arguments[1])
try generator.generate(page: page, to: "index.html", pretty: true)
EOF

RENDER_LOG="$RENDER_DIR/build.log"
if (cd "$RENDER_DIR" && swift run RenderSmokeTest "$RENDER_DIR/out" > "$RENDER_LOG" 2>&1); then
    if head -1 "$RENDER_DIR/out/index.html" | grep -q '<!DOCTYPE html>' \
        && grep -q '<h1>It renders</h1>' "$RENDER_DIR/out/index.html" \
        && grep -q '&lt;ok&gt;' "$RENDER_DIR/out/index.html"; then
        ok "rendered a page with a doctype, a table and escaped content"
    else
        fail "render produced unexpected output"
        head -20 "$RENDER_DIR/out/index.html" 2>/dev/null
    fi
else
    fail "the render smoke test did not build or run"
    tail -20 "$RENDER_LOG"
fi

step "winged CLI"
CLI_DIR="$(mktemp -d)"
trap 'rm -rf "$RENDER_DIR" "$CLI_DIR"' EXIT
CLI="$ROOT/.build/debug/winged"

if [ ! -x "$CLI" ]; then
    fail "the winged binary was not built"
else
    CLI_LOG="$CLI_DIR/cli.log"
    # Point the scaffolded project at this checkout instead of the published version.
    if "$CLI" new SmokeSite --path "$CLI_DIR/SmokeSite" > "$CLI_LOG" 2>&1 \
        && sed -i.bak "s|.package(url: \"https://github.com/micheltlutz/Winged-Swift.git\", from: \"[^\"]*\")|.package(path: \"$ROOT\")|" "$CLI_DIR/SmokeSite/Package.swift" \
        && "$CLI" build --path "$CLI_DIR/SmokeSite" >> "$CLI_LOG" 2>&1 \
        && grep -q "<!DOCTYPE html>" "$CLI_DIR/SmokeSite/dist/index.html" \
        && grep -q "<html lang=" "$CLI_DIR/SmokeSite/dist/index.html" \
        && [ -f "$CLI_DIR/SmokeSite/AGENTS.md" ]; then
        ok "winged new + winged build produced a site"
    else
        fail "the winged CLI smoke test failed"
        tail -20 "$CLI_LOG"

        # Narrow it down: is the scaffolded product itself unrunnable here, or only when
        # spawned through `winged`?
        PRODUCT="$CLI_DIR/SmokeSite/.build/debug/SmokeSite"
        printf "\n--- diagnostics ---\n"
        echo "uname: $(uname -mrs)"
        echo "swift: $(swift --version 2>&1 | head -1)"
        if [ -f "$PRODUCT" ]; then
            ls -l "$PRODUCT"
            file "$PRODUCT" 2>&1 | head -1
            codesign -dv "$PRODUCT" 2>&1 | head -3
            echo "--- running the product directly:"
            "$PRODUCT" "$CLI_DIR/SmokeSite/dist-direct"
            echo "direct exit: $?"
        else
            echo "no product at $PRODUCT"
            ls -R "$CLI_DIR/SmokeSite/.build/debug" 2>/dev/null | head -10
        fi
        echo "--- swift run from bash:"
        (cd "$CLI_DIR/SmokeSite" && swift run SmokeSite dist-bash > /dev/null 2>&1)
        echo "bash swift run exit: $?"
    fi
fi

printf "\n"
if [ "$FAILURES" -eq 0 ]; then
    ok "everything passed"
    exit 0
fi
fail "$FAILURES step(s) failed"
exit 1
