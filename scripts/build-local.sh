#!/usr/bin/env bash
# Baut little helper als DMG ohne Apple Developer Account.
# Kein Notarytool, kein Developer ID Zertifikat nötig.
#
# Voraussetzungen:
#   brew install xcodegen
#
# Verwendung:
#   ./scripts/build-local.sh
#
# Das fertige DMG landet in build/little-helper-VERSION.dmg
# Beim ersten Öffnen auf einem anderen Mac: Rechtsklick → Öffnen

set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────

APP_NAME="little helper"
SCHEME="little helper"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/build"

VERSION=$(defaults read "$ROOT/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "0.1.0")
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
APP_PATH="$BUILD_DIR/$APP_NAME.app"
DMG_STAGING="$BUILD_DIR/dmg-staging"
DMG_PATH="$BUILD_DIR/little-helper-$VERSION.dmg"

# ─── Helpers ─────────────────────────────────────────────────────────────────

step() { echo; echo "▶ $*"; }

# ─── Preflight ───────────────────────────────────────────────────────────────

step "Preflight"
command -v xcodebuild &>/dev/null || { echo "✗ Xcode nicht gefunden"; exit 1; }
command -v xcodegen  &>/dev/null || { echo "✗ xcodegen nicht gefunden — brew install xcodegen"; exit 1; }

mkdir -p "$BUILD_DIR"
rm -rf "$ARCHIVE_PATH" "$APP_PATH" "$DMG_STAGING" "$DMG_PATH"

# ─── Step 1: xcodegen ────────────────────────────────────────────────────────

step "xcodegen generate"
cd "$ROOT"
xcodegen generate --quiet

# ─── Step 2: Archive ─────────────────────────────────────────────────────────

step "Archive (Release, ad-hoc)"
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -quiet \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="-" \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

# ─── Step 3: .app aus Archive extrahieren ────────────────────────────────────

step ".app extrahieren"
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$APP_PATH"
echo "  $APP_PATH"

# ─── Step 4: DMG erstellen ───────────────────────────────────────────────────

step "DMG erstellen"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  -quiet \
  "$DMG_PATH"

rm -rf "$DMG_STAGING"
echo "  $DMG_PATH"

# ─── Done ────────────────────────────────────────────────────────────────────

echo
echo "✅  build/little-helper-$VERSION.dmg"
echo
echo "   Installation: DMG öffnen → App in Applications ziehen"
echo "   Erster Start auf fremdem Mac: Rechtsklick → Öffnen (einmalig)"
