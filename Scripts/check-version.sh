#!/bin/bash
#
# The version lives in two Swift sources — the CLI (`winged --version`, and the dependency it
# writes into new projects) and the library (`WingedSwift.version`). This keeps them equal, and
# equal to the release tag when one is given.
#
# Usage: ./Scripts/check-version.sh [vX.Y.Z]

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CLI=$(sed -n 's/.*version: "\([0-9][0-9.]*\)".*/\1/p' "$ROOT/Sources/WingedCLI/Winged.swift")
LIBRARY=$(sed -n 's/.*case VERSION = "\([0-9][0-9.]*\)".*/\1/p' "$ROOT/Sources/WingedSwift/WingedSwift.swift")

if [ -z "$CLI" ] || [ -z "$LIBRARY" ]; then
    echo "❌ could not read the version (CLI: '$CLI', library: '$LIBRARY')"
    exit 1
fi

if [ "$CLI" != "$LIBRARY" ]; then
    echo "❌ CLI is $CLI but WingedSwift.version is $LIBRARY"
    exit 1
fi

if [ $# -gt 0 ]; then
    TAG="${1#refs/tags/}"
    if [ "${TAG#v}" != "$CLI" ]; then
        echo "❌ tag $TAG does not match the sources ($CLI)"
        exit 1
    fi
    if ! grep -q "^## \[$CLI\]" "$ROOT/CHANGELOG.md"; then
        echo "❌ CHANGELOG.md has no ## [$CLI] section"
        exit 1
    fi
fi

echo "✅ version $CLI"
