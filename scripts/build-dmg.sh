#!/usr/bin/env bash
# Build, sign, notarize and package little helper as a distributable DMG.
#
# Prerequisites (one-time setup):
#   brew install create-dmg
#   xcrun notarytool store-credentials "notarytool" \
#     --apple-id "schult.sebastian@googlemail.com" \
#     --team-id "$TEAM_ID" \
#     --password "APP_SPECIFIC_PASSWORD"   # https://appleid.apple.com → App-specific passwords
#
# Usage:
#   TEAM_ID=XXXXXXXXXX ./scripts/build-dmg.sh
#
# Environment variables:
#   TEAM_ID                     Apple Developer Team ID (required)
#   NOTARYTOOL_PROFILE          Keychain profile name (default: notarytool)

set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────

APP_NAME="little helper"
SCHEME="little helper"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/build"

VERSION=$(defaults read "$ROOT/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "0.1.0")
TEAM_ID="${TEAM_ID:?'TEAM_ID environment variable is required. Run: TEAM_ID=XXXXXXXXXX ./scripts/build-dmg.sh'}"
NOTARYTOOL_PROFILE="${NOTARYTOOL_PROFILE:-notarytool}"

ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
APP_PATH="$EXPORT_PATH/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/little-helper-$VERSION.dmg"

# ─── Helpers ─────────────────────────────────────────────────────────────────

step() { echo; echo "▶ $*"; }
check_tool() { command -v "$1" &>/dev/null || { echo "✗ '$1' not found. Install: $2"; exit 1; }; }

# ─── Preflight ───────────────────────────────────────────────────────────────

step "Preflight"
check_tool xcodebuild "Xcode"
check_tool xcodegen   "brew install xcodegen"
check_tool create-dmg "brew install create-dmg"

mkdir -p "$BUILD_DIR"
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH" "$DMG_PATH"

# ─── Step 1: Generate Xcode project ──────────────────────────────────────────

step "xcodegen generate"
cd "$ROOT"
xcodegen generate --quiet

# ─── Step 2: Archive ─────────────────────────────────────────────────────────

step "Archive (Release)"
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -quiet \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Developer ID Application"

echo "  Archive: $ARCHIVE_PATH"

# ─── Step 3: Export ──────────────────────────────────────────────────────────

step "Export"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$ROOT/ExportOptions.plist" \
  -quiet

echo "  App: $APP_PATH"

# ─── Step 4: Create DMG ──────────────────────────────────────────────────────

step "Create DMG"
create-dmg \
  --volname "$APP_NAME $VERSION" \
  --window-size 640 400 \
  --icon-size 128 \
  --icon "$APP_NAME.app" 160 185 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 480 185 \
  "$DMG_PATH" \
  "$EXPORT_PATH/"

echo "  DMG: $DMG_PATH"

# ─── Step 5: Notarize ────────────────────────────────────────────────────────

step "Notarize"
xcrun notarytool submit "$DMG_PATH" \
  --keychain-profile "$NOTARYTOOL_PROFILE" \
  --wait

# ─── Step 6: Staple ──────────────────────────────────────────────────────────

step "Staple"
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"

# ─── Done ────────────────────────────────────────────────────────────────────

echo
echo "✅ Done: $DMG_PATH"
echo "   Version: $VERSION"
echo "   Ready to distribute."
