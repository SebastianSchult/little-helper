# ROADMAP.md

## Current Phase

- **Phase:** 5 — Stabilisierung & Distribution
- **Goal:** Notarized DMG, Onboarding, Whisper Pre-load
- **Timeframe:** ab 2026-06-12

## Milestones

| Milestone | Target | Status | Notes |
|---|---|---|---|
| Phase 1: Foundation | Kern-Pipeline läuft end-to-end | Done | Abgeschlossen 2026-06-10 |
| Phase 2: UI & Feedback | RecordingOverlay, Waveform, Click-to-insert | Done | Abgeschlossen 2026-06-11 |
| Phase 3: Settings | Konfigurierbares Modell, Sprache, Hotkey | Done | Abgeschlossen 2026-06-11 |
| Phase 4: AI Enhancement | Füllwörter, Interpunktion, Ollama optional | Done | Abgeschlossen 2026-06-12 |

## Roadmap Sync Policy

- If all open items in `Planned Work` are completed, milestones must be checked immediately.
- If at least one milestone remains `Planned` or `In progress`, add a new prioritized open sequence under `Planned Work`.
- If all milestones are complete:
  - set all milestone statuses to `Done`
  - add `All milestones completed on YYYY-MM-DD`
  - mirror this status in project note, project roadmap note, and daily note.

## Planned Work

### Phase 2 — UI & Feedback (Abgeschlossen 2026-06-11)

- [x] 1. RecordingOverlay: zentriertes Floating NSPanel über allen Fenstern (2026-06-10)
- [x] 2. WaveformView: Canvas-basierte Echtzeit-Wellenform in der Overlay (2026-06-10)
- [x] 3. Menu-Bar-Icon-States: idle / recording (rot) / processing (orange) / ready (grün) (2026-06-10)
- [x] 4. Click-to-insert Flow: .ready-State, Text in Clipboard, Klick → ⌘V (2026-06-11)
- [x] 5. Overlay zeigt Transkription + Einfüge-Anleitung im ready-State (2026-06-11)

### Phase 3 — Settings (Abgeschlossen 2026-06-11)

- [x] 6. SettingsView: Modell-Auswahl (tiny/base/small/medium) + Download-Progress
- [x] 7. Sprach-Auswahl (DE, EN, FR, ES, IT, PT)
- [x] 8. Hotkey anpassbar in Settings (KeyboardShortcuts.Recorder)
- [x] 9. Launch at Login (ServiceManagement Framework)
- [x] 10. Persistenz: UserDefaults für alle Settings

### Phase 5 — Stabilisierung & Distribution (Planned)

- [x] 15. (A) Notarized DMG: create-dmg + xcrun notarytool, verteilbares Installer-Package (2026-06-12)
- [x] 16. (B) Onboarding-Flow: Schritt-für-Schritt-Anleitung für Mic- + Accessibility-Permission beim ersten Start (2026-06-12)
- [x] 17. (C) Whisper Pre-load: Modell beim App-Start laden statt beim ersten Hotkey — erste Aufnahme sofort bereit (2026-06-12)

### Phase 4 — AI Enhancement (Planned)

- [x] 11. AIEnhancer: regelbasierter Füllwort-Filter (äh, ähm, uh, um, …)
- [x] 12. Interpunktion und Satz-Kapitalisierung via Post-Processing
- [x] 13. Ollama-Integration: optionale Grammatikkorrektur via localhost HTTP
- [x] 14. Enhancement on/off Toggle in Settings

### Completed Work

- [x] Repository mit Starter Pack initialisiert (2026-06-10)
- [x] Plan und Architektur festgelegt (2026-06-10)
- [x] MD-Dateien gefüllt (2026-06-10)
- [x] xcodegen-Projekt aufgesetzt, WhisperKit + KeyboardShortcuts als SPM-Dependencies (2026-06-10)
- [x] MenuBarExtra Skeleton — App läuft als Menu-Bar-App ohne Dock-Icon (2026-06-10)
- [x] AppDelegate + AppState (RecordingState/ModelState State Machine) (2026-06-10)
- [x] HotkeyManager — globaler Hotkey ⌘⇧Space via KeyboardShortcuts (2026-06-10)
- [x] AudioRecorder — AVAudioEngine, Aufnahme in temp WAV, Waveform-Tap (2026-06-10)
- [x] WhisperTranscriber — WhisperKit 0.18, Modell openai_whisper-tiny, transcribe() async (2026-06-10)
- [x] TextInserter — AXUIElement insert + Clipboard Fallback (2026-06-10)
- [x] Accessibility Permission Request beim ersten Start (2026-06-10)
- [x] End-to-End Test erfolgreich: Hotkey → Aufnahme → Transkription → Text eingefügt (2026-06-10)
- [x] Bugfix: falscher Modellname openai/whisper-tiny → openai_whisper-tiny (2026-06-10)

## Dependencies

- WhisperKit setzt Apple Silicon (M1+) voraus
- macOS 14 (Sonoma)+ als Deployment Target
- Ollama muss vom User separat installiert werden (Phase 4, optional)

## Change Log

- 2026-06-10: Projekt initialisiert, Phase 1 vollständig abgeschlossen
- 2026-06-11: Phase 2 + Phase 3 abgeschlossen
- 2026-06-12: Phase 4 abgeschlossen — All milestones completed on 2026-06-12
