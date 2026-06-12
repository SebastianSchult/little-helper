# little helper

Native macOS Menu-Bar-App für lokale Spracheingabe. Globaler Hotkey startet die Aufnahme, [WhisperKit](https://github.com/argmaxinc/WhisperKit) transkribiert vollständig offline auf Apple Silicon, der Text wird via Clipboard an der Cursor-Position eingefügt — keine Cloud, keine Subscription, keine Latenz durch externe APIs.

## Features

- **Globaler Hotkey** — ⌘⇧Space (konfigurierbar), funktioniert in jeder App
- **Offline-Transkription** — WhisperKit via Core ML, Apple Silicon optimiert
- **Waveform-Overlay** — visuelles Echtzeit-Feedback während der Aufnahme
- **Click-to-insert** — Text landet genau dort, wo du klickst
- **KI-Enhancement** — regelbasierter Füllwort-Filter + optionale Grammatikkorrektur via Ollama
- **Konfigurierbare Modelle** — Whisper tiny / base / small / medium
- **Mehrsprachig** — DE, EN, FR, ES, IT, PT
- **Launch at Login** — optional

## Anforderungen

- macOS 14 (Sonoma) oder neuer
- Apple Silicon (M1–M5) — WhisperKit nutzt den Core ML Neural Engine
- ~150 MB für das tiny-Modell (einmaliger Download beim ersten Start)
- [Ollama](https://ollama.com) optional für KI-Grammatikkorrektur

## Installation

Aktuell nur als selbst gebaute App verfügbar (notarized DMG folgt in Phase 5):

```bash
# Abhängigkeiten
brew install xcodegen

# Repo klonen
git clone https://github.com/SebastianSchult/little-helper.git
cd little-helper

# Xcode-Projekt generieren
xcodegen generate

# In Xcode öffnen und bauen
open "little helper.xcodeproj"
```

Beim ersten Start:
1. **Mikrofon-Berechtigung** — beim ersten Hotkey-Druck angefragt
2. **Accessibility-Berechtigung** — direkt beim App-Start angefragt (System Settings → Datenschutz → Bedienungshilfen)
3. **Whisper-Modell** — wird im Hintergrund geladen (~150 MB tiny, einmalig)

## Verwendung

| Aktion | Beschreibung |
|--------|-------------|
| `⌘⇧Space` | Aufnahme starten |
| `⌘⇧Space` (nochmal) | Aufnahme stoppen und transkribieren |
| Klick ins Textfeld | Text an Cursor-Position einfügen |
| Menu-Bar-Icon | Status einsehen, Einstellungen öffnen |

**Icon-Zustände:**

| Icon | Farbe | Bedeutung |
|------|-------|-----------|
| `mic` | grau | Bereit |
| `mic.fill` | rot | Aufnahme läuft |
| `waveform` | orange | Transkription läuft |
| `text.bubble` | grün | Text bereit — klicken zum Einfügen |
| `exclamationmark.triangle` | rot | Fehler |

## Konfiguration

Einstellungen öffnen: Menu-Bar-Icon → ⚙ Einstellungen

| Einstellung | Optionen | Default |
|-------------|----------|---------|
| Whisper-Modell | tiny / base / small / medium | tiny |
| Sprache | DE, EN, FR, ES, IT, PT | DE |
| Hotkey | frei konfigurierbar | ⌘⇧Space |
| Launch at Login | an/aus | aus |
| AI Enhancement | an/aus | aus |
| Ollama-Grammatikkorrektur | an/aus + Modellauswahl | aus |

## Tech Stack

| Komponente | Technologie |
|------------|------------|
| Sprache | Swift 5.9+, SwiftUI |
| Audio | AVAudioEngine |
| ML / Transkription | WhisperKit 0.18 (Core ML) |
| Globaler Hotkey | KeyboardShortcuts (sindresorhus) |
| Text-Einfügen | NSPasteboard + CGEvent ⌘V |
| AI Enhancement | Regelbasiert (AIEnhancer) + Ollama optional |
| Build | xcodegen + Xcode |

## Projektstruktur

```
src/
├── LittleHelperApp.swift       ← App-Einstiegspunkt
├── AppDelegate.swift           ← App-Lifecycle, Permissions
├── AppState.swift              ← State Machine (idle/recording/processing/ready/error)
├── Audio/                      ← AVAudioEngine, Waveform-Analyse
├── Transcription/              ← WhisperKit, Modell-Management
├── Input/                      ← Hotkey, Text-Insertion
├── Enhancement/                ← AIEnhancer, OllamaEnhancer
└── UI/                         ← Overlay, Waveform, Menu, Settings
```

Weitere Details: [ARCHITECTURE.md](ARCHITECTURE.md) · [DECISIONS.md](DECISIONS.md) · [ROADMAP.md](ROADMAP.md)

## Bekannte Einschränkungen

- Apple Silicon Pflicht (Intel-Macs nicht unterstützt)
- Kein App Store (Accessibility API inkompatibel mit App Sandbox)
- Erster Start braucht Internetverbindung für Modell-Download
- Ollama muss separat installiert werden

## Lizenz

Persönliches Projekt. Kein offizielles Lizenz-Statement — bei Interesse melden.
