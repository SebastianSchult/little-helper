# DEVSECOPS.md

## Build and Deploy

- Build via Xcode (GUI) oder `xcodebuild` CLI
- Kein CI für persönliche Nutzung — bei öffentlicher Distribution GitHub Actions ergänzen
- Release-Build: Archive → Export → Notarize → DMG
- Debug-Build: direkt aus Xcode starten

## Distribution

Vollständiger Prozess in einem Skript:

```bash
TEAM_ID=DEIN_TEAM_ID ./scripts/build-dmg.sh
```

Erstellt: `build/little-helper-VERSION.dmg` (signiert, notarisiert, gestapelt).

Voraussetzungen und Troubleshooting → [docs/distribution.md](docs/distribution.md)

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
