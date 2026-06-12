# DECISIONS.md

## Decision Log

| Date | Decision | Reason | Consequence | Status |
|---|---|---|---|---|
| 2026-06-10 | Swift + SwiftUI als Tech Stack | Native macOS, beste System-Integration, keine Runtime-Abhängigkeiten | Kein Cross-Platform, nur macOS | Accepted |
| 2026-06-10 | WhisperKit statt whisper.cpp | Swift-native, kein C++ Bridge, Core ML optimiert für Apple Silicon | Intel Macs nicht unterstützt | Accepted |
| 2026-06-10 | LSUIElement (kein Dock-Icon) | Menu-Bar-Utility braucht keinen Dock-Platz | App nicht via Cmd+Tab erreichbar | Accepted |
| 2026-06-10 | Accessibility API als primäre Text-Insertion | Kein Clipboard-Overwrite, sauberere UX | Erfordert Accessibility-Berechtigung | Accepted |
| 2026-06-10 | Kein App Store | Accessibility API nicht kompatibel mit App Sandbox | Distribution via notarized DMG | Accepted |
| 2026-06-10 | macOS 14+ als Deployment Target | Stabile SwiftUI + AVAudioEngine APIs, Apple Silicon Standard | Ältere Macs ausgeschlossen | Accepted |
| 2026-06-10 | Regelbasiertes Enhancement als MVP, Ollama optional | Keine externen Abhängigkeiten im Core, erweiterbar | Grammatikkorrektur weniger präzise als LLM | Accepted |
| 2026-06-10 | MenuBarExtra statt NSStatusItem | NSStatusItem zeigt unter macOS 26 kein Icon — MenuBarExtra ist der native SwiftUI-Weg seit macOS 13 | — | Accepted |
| 2026-06-10 | WhisperKit Modellname: openai_whisper-tiny (Unterstrich) | WhisperKit 0.18 erwartet Unterstriche im Modellnamen, nicht Slashes | Modellnamen in Settings müssen mit Unterstrich gepflegt werden | Accepted |
| 2026-06-11 | Click-to-insert statt Auto-insert | Auto-insert trifft oft falsches Ziel; User soll selbst entscheiden wo Text landet | Leicht mehr Interaktion nötig, dafür zuverlässig | Accepted |
| 2026-06-11 | Clipboard + ⌘V statt AXUIElement für Insertion | AXUIElement-Schreiben schlägt in vielen Apps still fehl; ⌘V funktioniert überall | Text liegt kurz in Clipboard | Accepted |
| 2026-06-11 | `openSettings()` statt `SettingsLink` in MenuBarExtra | `SettingsLink` schließt Popup bevor Settings-Fenster erscheint — bekannter SwiftUI-Bug | Erfordert `@Environment(\.openSettings)` | Accepted |
| 2026-06-12 | UserDefaults mit `didSet`-Pattern statt `@AppStorage` | `@AppStorage` nur in SwiftUI Views, nicht in `ObservableObject`; `didSet` ist sauberer für AppState | — | Accepted |
| 2026-06-12 | Ollama-Default: llama3.2:3b | Schnellste Option mit gutem Deutsch-Support (~2GB, ~1-2s Latenz); deepseek-r1:7b zu langsam (Reasoning-Modell) | User muss Modell einmalig pullen | Accepted |
| 2026-06-12 | Ollama-Prompt: CRITICAL-Direktive für Zielsprache | llama3.2:3b antwortet standardmäßig in der Prompt-Sprache (Englisch) — explizite Anweisung nötig | Prompt muss bei Modellwechsel getestet werden | Accepted |
| 2026-06-12 | xcodegen nach neuen Swift-Dateien neu generieren | `.xcodeproj` ist statisch; neue Dateien in `src/` brauchen `xcodegen generate` um ins Build aufgenommen zu werden | Workflow-Schritt nach neuen Dateien | Accepted |
| 2026-06-12 | Whisper Pre-load beim App-Start statt lazy beim ersten Hotkey | Erste Aufnahme hatte merkliche Verzögerung durch Modell-Load; bei App-Start ist der User noch nicht aktiv, daher guter Zeitpunkt | `modelState` kann beim Hotkey-Press `.loading` sein — Race Condition via Poll-Wait gelöst | Accepted |
| 2026-06-12 | `.xcodeproj` nicht in Git — nur `project.yml` | `.xcodeproj` ist xcodegen-Artefakt; `project.yml` ist Source of Truth — beide committen führt zu Merge-Konflikten | `xcodegen generate` nach Clone nötig | Accepted |

## Decision Template

```md
# Decision XXX

## Context
Why is this needed?

## Decision
What was decided?

## Reasoning
Why was this chosen?

## Tradeoffs
What are the downsides?

## Constraints
What must remain respected later?

## Status
Accepted / Deprecated / Experimental
```

---

# Decision 001 — WhisperKit als ML-Backend

## Context
Whisper-Transkription auf macOS kann über mehrere Backends laufen: whisper.cpp (C++), faster-whisper (Python), WhisperKit (Swift/Core ML), Apple Speech Framework.

## Decision
WhisperKit von Argmax wird als einziges ML-Backend verwendet.

## Reasoning
- Swift-native SPM-Package, kein C++ Bridge oder Python Runtime nötig
- Core ML Optimierung für Apple Silicon (M1–M5) — schnellste lokale Inferenz
- Aktiv gepflegt, unterstützt alle Whisper-Modellgrößen
- Hugging Face Model Hub Integration für einfachen Download

## Tradeoffs
- Intel Macs nicht unterstützt (Core ML Neural Engine nur Apple Silicon)
- Abhängigkeit von Argmax als Maintainer

## Constraints
- App setzt Apple Silicon voraus — muss in der UI kommuniziert werden
- Modelle werden beim ersten Start heruntergeladen, brauchen Fortschrittsanzeige

## Status
Accepted

---

# Decision 002 — Accessibility API für Text-Insertion

## Context
Text an der aktuellen Cursor-Position einfügen kann über zwei Wege passieren:
1. Clipboard-Methode: Text in Pasteboard schreiben, Cmd+V simulieren
2. Accessibility API: `AXUIElement` des fokussierten Elements direkt beschreiben

## Decision
Accessibility API als primäre Methode, Clipboard+CGEvent als Fallback.

## Reasoning
- Clipboard-Methode überschreibt den bestehenden Clipboard-Inhalt des Users
- AXUIElement ist die sauberere, nicht-destruktive Methode
- Fallback stellt sicher, dass es in jedem Kontext funktioniert

## Tradeoffs
- Erfordert Accessibility-Berechtigung in System Settings
- User muss aktiv die Berechtigung vergeben (einmalig)

## Constraints
- Onboarding-Flow muss Accessibility-Permission-Setup klar erklären
- Fallback (Clipboard) muss immer implementiert bleiben

## Status
Accepted
