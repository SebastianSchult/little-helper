# SECURITY.md

## Security Rules

- Never commit secrets, API keys, tokens, or credentials.
- Use `Config.xcconfig` (gitignored) for any build-time secrets.
- Validate all external input — insbesondere wenn Ollama HTTP-Responses verarbeitet werden.
- No outbound network after initial model download.

## Required Permissions

### Microphone Access
- Entitlement: `com.apple.security.device.audio-input`
- Info.plist key: `NSMicrophoneUsageDescription`
- Request: Beim ersten Hotkey-Druck, mit klarer Erklärung

### Accessibility API
- Entitlement: `com.apple.security.temporary-exception.accessibility`
- System Settings: Security & Privacy → Accessibility → little helper
- Request: Beim ersten Start, mit Onboarding-Guide
- Fallback: Clipboard-Methode wenn nicht gewährt

### No App Sandbox
- Entitlement: `com.apple.security.app-sandbox = false`
- Notwendig für Accessibility API full access
- Konsequenz: Kein App Store, Distribution via notarized DMG

## Authentication and Access

- Keine Benutzer-Authentifizierung notwendig (lokale Einzelnutzer-App).
- Accessibility Permission wird vom OS verwaltet — kein Custom Auth-Layer.
- Lokale Modelldaten (WhisperKit Cache) landen in `~/Library/Application Support/little-helper/`.

## Distribution Security

- App muss notarisiert werden vor Distribution: `xcrun notarytool submit`
- Code Signing: Apple Developer ID Application Certificate erforderlich
- Hardened Runtime aktivieren für Notarisierung

## Ollama Integration (Phase 4)

- Nur localhost (`http://127.0.0.1:11434`) — kein Remote-Zugriff
- Response-Inhalte werden nicht ausgeführt, nur als String weiterverarbeitet
- Ollama-Integration ist optional und off by default
