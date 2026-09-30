#!/usr/bin/env bash
# Rebuilds dist/theme-hotel-v2.swf from original/theme-hotel-v1.swf + src/
# Requires Java 11+ and network access to registry.npmjs.org (to fetch FFDec).
set -euo pipefail
cd "$(dirname "$0")"
TOOLS=.tools
FFDEC="$TOOLS/jpexs/package/bin/ffdec.jar"
if [ ! -f "$FFDEC" ]; then
  echo "Downloading JPEXS FFDec (npm package jpexs-ts)..."
  mkdir -p "$TOOLS/jpexs"
  curl -sSL https://registry.npmjs.org/jpexs-ts/-/jpexs-ts-0.2.0.tgz | tar xz -C "$TOOLS/jpexs"
fi
# FFDec's AS3 compiler needs the Flash Player API definitions (playerglobal.swc)
FLASHLIB="$HOME/.FFDec/flashlib"
if ! ls "$FLASHLIB"/playerglobal*.swc >/dev/null 2>&1; then
  echo "Downloading playerglobal.swc (Flash Player 11.1 API)..."
  mkdir -p "$FLASHLIB"
  curl -sSL -o "$FLASHLIB/playerglobal11_1.swc" \
    https://raw.githubusercontent.com/nexussays/playerglobal/master/11.1/playerglobal.swc
fi

# FFDec looks for "<folder>/scripts/<package>/<Class>.as"
rm -rf .build && mkdir -p .build/scripts dist
cp -r src/. .build/scripts/
java -Djava.awt.headless=true -jar "$FFDEC" -importScript original/theme-hotel-v1.swf dist/theme-hotel-v2.swf .build 2>&1 \
  | { grep -v "^Picked up JAVA_TOOL_OPTIONS" || true; } | tee .build/import.log
if grep -qiE "error|SEVERE" .build/import.log; then
  echo "Script import failed" >&2
  exit 1
fi
ls -la dist/theme-hotel-v2.swf
