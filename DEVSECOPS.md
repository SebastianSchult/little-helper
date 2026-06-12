# DEVSECOPS.md

## Build and Deploy

- Build via Xcode (GUI) oder `xcodebuild` CLI
- Kein CI für persönliche Nutzung — bei öffentlicher Distribution GitHub Actions ergänzen
- Release-Build: Archive → Export → Notarize → DMG
- Debug-Build: direkt aus Xcode starten

## Distribution

```bash
# Archive
xcodebuild -scheme "little helper" -configuration Release archive \
  -archivePath ./build/little-helper.xcarchive

# Export .app
xcodebuild -exportArchive \
  -archivePath ./build/little-helper.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ExportOptions.plist

# Notarize
xcrun notarytool submit ./build/export/little\ helper.app \
  --apple-id "schult.sebastian@googlemail.com" \
  --team-id TEAM_ID \
  --wait

# Staple
xcrun stapler staple ./build/export/little\ helper.app
```

## Environments

- **Development:** Debug-Build, direkt in Xcode, kein Notarization nötig
- **Personal Production:** Release-Build, notarisiert, als .app oder DMG

## Operations

- Logging: `os.Logger` (OSLog) für alle kritischen Pfade (Hotkey, Recording, Transcription)
- Crashes: macOS Crash Reporter schreibt nach `~/Library/Logs/DiagnosticReports/`
- Kein Remote-Monitoring nötig für lokale App

## Model Management

- WhisperKit-Modelle landen in `~/Library/Application Support/little-helper/models/`
- Beim ersten Start wird `openai_whisper-tiny` automatisch heruntergeladen (~150MB)
- Größere Modelle auf User-Anfrage via Settings
