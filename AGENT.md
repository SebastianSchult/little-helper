# AGENT.md

> Repository-level AI rules for a SebsBrain project.

## Purpose

This repository is part of the SebsBrain ecosystem.

SebsBrain is:
- a persistent engineering memory
- an AI-native development environment
- a modular knowledge operating system
- an agentic software engineering platform

The goal is not only faster development.

The goal is:
- maintainable systems
- preserved architecture
- scalable engineering
- long-term knowledge retention
- AI-assisted quality engineering

## Project Overview

- **Project Name:** little helper
- **Description:** Native macOS Menu-Bar-App für lokale Spracheingabe. Globaler Hotkey startet Mikrofon-Aufnahme, WhisperKit transkribiert lokal auf Apple Silicon, Text wird via Accessibility API an der aktuellen Cursor-Position eingefügt.
- **Primary Goal:** Schnelle, offline-fähige Diktierfunktion für jeden macOS-Kontext — keine Cloud, keine Subscription, keine Latenz durch externe APIs.
- **App Type:** macOS Menu Bar App (LSUIElement, kein Dock-Icon)
- **Frontend:** SwiftUI (RecordingOverlay, SettingsView, MenuBarView, WaveformView)
- **Backend:** Kein separates Backend — alles läuft lokal in der App
- **ML:** WhisperKit (Argmax) via Core ML, Apple Silicon optimiert
- **Infrastructure:** Lokale App, kein Server, kein Cloud-Service
- **Architecture Style:** Modularer Monolith mit klaren Schichtgrenzen (Audio / ML / Input / Enhancement / UI)

## Technology Stack

- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **Audio:** AVAudioEngine
- **ML/Transcription:** WhisperKit (SPM, Argmax/WhisperKit)
- **Global Hotkey:** KeyboardShortcuts (SPM, sindresorhus/KeyboardShortcuts)
- **Text Insertion:** Accessibility API (AXUIElement) + Clipboard Fallback
- **AI Enhancement:** Regelbasiert (Phase 4) + optionales Ollama
- **Build:** Xcode + Swift Package Manager
- **Target:** macOS 14 (Sonoma)+, Apple Silicon (M1–M5)

## SebsBrain Sync Rule

- SebsBrain Vault path: `/Users/sebastianschult/Dokumente/SebsBrain/SebsBrain`
- If project work happened on a given day, complete SebsBrain sync on the same day:
  - project note
  - project roadmap
  - daily note

## Module Structure

```
src/
├── LittleHelperApp.swift       ← App entry point, LSUIElement config
├── AppDelegate.swift           ← NSStatusItem, Menu Bar setup, App lifecycle
├── AppState.swift              ← ObservableObject: recording/processing state, settings
├── Audio/
│   ├── AudioRecorder.swift     ← AVAudioEngine, mic capture, waveform buffer tap
│   └── WaveformAnalyzer.swift  ← Audio buffer → normalized Float array for UI
├── Transcription/
│   ├── WhisperTranscriber.swift ← WhisperKit wrapper, transcribe(audioURL:) async
│   └── ModelManager.swift      ← Model download, cache, selection (tiny/base/small/medium)
├── Input/
│   ├── HotkeyManager.swift     ← KeyboardShortcuts registration, start/stop toggle
│   └── TextInserter.swift      ← AXUIElement insert, Clipboard+CGEvent fallback
├── Enhancement/
│   └── AIEnhancer.swift        ← Filler word removal, punctuation, optional Ollama
└── UI/
    ├── RecordingOverlay.swift  ← Floating NSPanel, anchored to screen center
    ├── WaveformView.swift      ← Canvas-based real-time waveform
    ├── MenuBarView.swift       ← SwiftUI menu behind status bar icon
    └── SettingsView.swift      ← Model selection, language, hotkey, enhancement toggle
```

## Coding Standards

### General Principles

- Prioritize readability, maintainability, modularity, and predictable behavior.
- Avoid overengineering, duplicated logic, giant files, hidden side effects.
- `async/await` for all async operations — no completion-handler callbacks.
- Errors propagate via `throws` — never silently discarded.
- No force-unwraps (`!`) except where provably safe and documented why.

### Swift / SwiftUI Rules

- Use `@MainActor` for all UI-touching code.
- `ObservableObject` + `@Published` for shared state in `AppState`.
- Keep SwiftUI Views dumb — no business logic inside View bodies.
- Use `Canvas` for the waveform (not Shape-based, performance matters here).
- Audio and ML work happens off the main thread via `Task` + `actor` isolation.

### macOS-Specific Rules

- App must run as `LSUIElement` (no Dock icon, only Menu Bar).
- Always check and request permissions before using microphone or Accessibility API.
- Never block the main thread — all AVAudioEngine and WhisperKit calls are async.
- Global hotkey must work even when the app has no focused window.

## Architecture Rules

- Audio layer has no knowledge of UI or ML — it emits buffers and state only.
- ML layer (WhisperTranscriber) takes an audio file URL, returns a String — no side effects.
- TextInserter is completely independent of how the text was produced.
- AppState is the single source of truth for the recording/processing/idle state machine.
- No circular dependencies between modules.

## AI Behavior Rules

- Preserve existing architecture and working systems.
- Prefer incremental changes and explain important modifications.
- Minimize unnecessary rewrites.
- Keep changes roughly within a 300 LOC reviewable chunk when possible.
- Do not silently remove features or introduce dependencies without reason.
- When touching AVAudioEngine or WhisperKit code: always verify thread safety.

## Security Constraints

- Never commit secrets, API keys, tokens, or credentials.
- Microphone permission: request only at first hotkey press, never silently.
- Accessibility permission: explain clearly why it's needed before requesting.
- No outbound network calls after initial model download.

## Deployment Rules

- Distribution: direct DMG or notarized .app — no App Store (Accessibility API requires entitlements incompatible with sandbox).
- Notarization via `xcrun notarytool` before distributing to others.
- No CI required for personal use; add GitHub Actions if distributing.

## QA Requirements

- Happy path: hotkey → recording starts → speak → hotkey again → text appears at cursor.
- Edge cases: no microphone permission, no accessibility permission, model not downloaded, recording with no speech, very long recording (>60s).
- Verify on Apple Silicon only (WhisperKit requirement).

## Known Limitations

- Apple Silicon (M1+) required — WhisperKit uses Core ML which is not optimized for Intel.
- macOS 14+ required for stable SwiftUI + AVAudioEngine APIs used.
- Accessibility API requires user to grant permission in System Settings — must guide user clearly.
- First launch requires internet for model download (tiny model ~150MB, medium ~1.5GB).

## Roadmap Sync Rule (Mandatory)

- Every time `ROADMAP.md` changes, compare `Planned Work` against all milestone statuses.
- If all current open planned items are done (`[x]`) but at least one milestone is still `Planned` or `In progress`, immediately add a new prioritized open sequence under `Planned Work`.
- If all milestones are done:
  - set every milestone status to `Done`
  - add `All milestones completed on YYYY-MM-DD` in `ROADMAP.md`
  - mirror the status in project note, roadmap note, and the same-day daily note.
