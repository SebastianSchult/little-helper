# KNOWN_ISSUES.md

## Issue Register

| Issue | Impact | Workaround | Owner | Status |
|---|---|---|---|---|
| Intel Macs nicht unterstützt | WhisperKit benötigt Apple Silicon (Core ML Neural Engine) | whisper.cpp als Backend nachrüsten | Sebastian | Known Constraint |
| Accessibility Permission Onboarding | User muss manuell in System Settings navigieren | Klarer Guide im Onboarding-Screen | Sebastian | Open |
| Erstes Modell-Download benötigt Internet | Offline-Start nicht möglich beim allerersten Launch | Modell vorab in App-Bundle einzubetten (zu groß) | Sebastian | Known Constraint |
| No App Store Distribution | Accessibility API inkompatibel mit App Sandbox | DMG + Notarisierung | Sebastian | Accepted |

## Notes

- Keep this list current and actionable.
- Known Constraints sind bewusste architektonische Entscheidungen, keine Bugs.
