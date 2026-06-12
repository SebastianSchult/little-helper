# CLAUDE.md

> Zentrale Arbeitsanweisung für AI-gestützte Entwicklung in diesem Repository.
> Basiert auf [[Engineering/CLAUDE_CORE]] aus dem SebsBrain-Ökosystem.

## Projekt

- **Name:** little helper
- **Beschreibung:** Native macOS Menu-Bar-App für lokale Spracheingabe. Globaler Hotkey startet Aufnahme, Whisper transkribiert lokal, Text wird an Cursor-Position eingefügt.
- **Primäres Ziel:** Schnelle, offline-fähige Diktierfunktion für jeden macOS-Kontext — keine Cloud, keine Subscription.

## Arbeitsprinzipien

- Erst verstehen, dann ändern.
- Funktionierendes nur mit gutem Grund anfassen.
- Kleine, überprüfbare Änderungen bevorzugen (~300 LOC pro Chunk).
- Architektur, Tests und Dokumentation gehören immer zusammen.
- Unklare Anforderungen zuerst sichtbar machen, nicht erraten.

## Agentenverhalten

- Vor Änderungen kurz zusammenfassen, was verstanden wurde.
- Betroffene Dateien benennen.
- Risiken und offene Fragen aktiv sichtbar machen.
- Keine großflächigen Rewrites ohne klare Begründung.
- Wenn mehrere Wege möglich sind, die sicherste und wartbarste Option bevorzugen.

## Git-Workflow (Pflicht)

- Nach jeder abgeschlossenen Änderung: `git add` → `git commit` → `git push`.
- Kein unfertiges oder halb-funktionierendes Commit — nur wenn der Stand lauffähig ist.
- Commit-Message: präzise, auf Englisch, mit `Co-Authored-By`-Zeile.

## Coding Standards

- Swift 5.9+, SwiftUI, strikte Typisierung, keine Force-Unwraps.
- Klare Trennung: Audio-Logik, ML-Logik, UI, Text-Insertion als separate Module.
- `async/await` für alle asynchronen Operationen (kein Callback-Chaos).
- Fehler explizit mit `throws` propagieren, nicht stumm schlucken.
- Kein UI-Code in Business-Logic-Schichten.

## Wichtige technische Kontextregeln

- Die App läuft als **LSUIElement** (kein Dock-Icon, nur Menu Bar).
- Text-Einfügen via **Accessibility API** (`AXUIElement`), Fallback auf Clipboard+Cmd+V.
- Whisper-Modelle werden via **WhisperKit** (Core ML, Apple Silicon) geladen — erster Start braucht Download.
- Globaler Hotkey via **KeyboardShortcuts** SPM-Package.
- Audio via **AVAudioEngine** (nicht AVAudioRecorder, brauchen Tap für Waveform).
- Alle Berechtigungen (Mikrofon, Accessibility) müssen explizit angefragt werden.
- **Kein Netzwerk nach Model-Download** — vollständig offline.

## Security

- Keine Secrets, API Keys oder Tokens committen.
- `.env` und `Config.xcconfig` für environment-spezifische Werte nutzen.
- Microphone und Accessibility Permissions nur wenn nötig anfordern, nie im Hintergrund.

## SebsBrain Sync

- Vault-Pfad: `/Users/sebastianschult/Dokumente/SebsBrain/SebsBrain`
- Wenn am Tag Projektarbeit stattgefunden hat: Projektnotiz, Roadmap und Daily Note am selben Tag synchronisieren.

## Verknüpfung

- Projektregeln & Stack-Details → `AGENT.md`
- Architektur-Übersicht → `ARCHITECTURE.md`
- Entscheidungslog → `DECISIONS.md`
- Roadmap & Milestones → `ROADMAP.md`
