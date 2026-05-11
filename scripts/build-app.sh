#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "→ Building Cleaaan (Release)..."
swift build -c release --product Cleaaan

APP="Cleaaan.app"
EXEC=".build/release/Cleaaan"
ICON_SRC="Assets/Icon/ICON COLOURED.png"
ICONSET="Resources/icon.iconset"

# ── App bundle skeleton ──────────────────────────────────────────────────────
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources/Fonts"

cp "$EXEC"                "$APP/Contents/MacOS/Cleaaan"
cp "Resources/Info.plist" "$APP/Contents/"
cp "Assets/Font/Generic-G20-FR-Classic-DEMO.otf" \
   "$APP/Contents/Resources/Fonts/"

# ── App icon ─────────────────────────────────────────────────────────────────
mkdir -p "$ICONSET"
for SIZE in 16 32 128 256 512; do
  sips -z $SIZE $SIZE "$ICON_SRC" --out "$ICONSET/icon_${SIZE}x${SIZE}.png" > /dev/null
done
# @2x variants (double each size up to 512)
sips -z 32  32  "$ICON_SRC" --out "$ICONSET/icon_16x16@2x.png"  > /dev/null
sips -z 64  64  "$ICON_SRC" --out "$ICONSET/icon_32x32@2x.png"  > /dev/null
sips -z 256 256 "$ICON_SRC" --out "$ICONSET/icon_128x128@2x.png" > /dev/null
sips -z 512 512 "$ICON_SRC" --out "$ICONSET/icon_256x256@2x.png" > /dev/null
# 512@2x would need 1024px source — skip (512 is used as fallback)

iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

# ── Ad-hoc code signature ────────────────────────────────────────────────────
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo ""
echo "✓  Built $APP"
echo "   Open with:  open $APP"
