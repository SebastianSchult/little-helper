# KNOWN_ISSUES.md

## Issue Register

| Issue | Impact | Workaround | Owner | Status |
|---|---|---|---|---|
| Intel Macs nicht unterstützt | WhisperKit benötigt Apple Silicon (Core ML Neural Engine) | whisper.cpp als Backend nachrüsten | Sebastian | Known Constraint |
| Accessibility Permission Onboarding | User muss manuell in System Settings navigieren | Onboarding-Flow vorhanden (Schritt 1), "Erneut prüfen"-Button | Sebastian | Resolved |
| AXIsProcessTrusted() bei ad-hoc Signing nicht live | Nach Permission-Grant in System Settings wird Status nicht automatisch erkannt | "Erneut prüfen"-Button im Onboarding, Soft-Gate (Weiter immer aktiv) | Sebastian | Workaround |
| Erster Start: Modell-Download blockiert UI | Erster Hotkey-Press startet Download (~150 MB) — App zeigt "Transkribiere…" für 1–3 min | Nach Download gecacht, alle Folgestarts sofort bereit | Sebastian | Known Constraint |
| No App Store Distribution | Accessibility API inkompatibel mit App Sandbox | DMG + Notarisierung | Sebastian | Accepted |

## Notes

- Keep this list current and actionable.
- Known Constraints sind bewusste architektonische Entscheidungen, keine Bugs.
