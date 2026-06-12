# ARCHITECTURE.md

## System Overview

- **Product:** little helper — native macOS Menu-Bar-App für lokale Spracheingabe
- **Problem:** Diktat / Spracheingabe auf macOS erfordert bisher Cloud-Dienste (Siri, Google) oder teure Apps. little helper läuft vollständig offline.
- **Core Subsystems:** Audio-Capture, ML-Transcription, Text-Insertion, AI-Enhancement, UI/Overlay, Settings

## Architecture Style

- **Style:** Modularer Monolith — eine native macOS App, klare Schichtgrenzen zwischen Modulen
- **Boundaries:** Audio → ML → Text, alle drei kennen sich nicht gegenseitig; AppState verbindet sie
- **State Model:** Zentraler `AppState` (ObservableObject) als Single Source of Truth für den Recording-State-Machine: `idle → recording → processing → idle`
- **Integration Model:** Kein externes Backend. WhisperKit läuft in-process via Core ML. Optionale Ollama-HTTP-Verbindung für KI-Enhancement (localhost).

## Module Boundaries

```
┌─────────────────────────────────────────────────────────┐
│                        AppState                          │
│         (ObservableObject, State Machine, Settings)      │
└───────────┬──────────────┬───────────────┬──────────────┘
            │              │               │
     ┌──────▼──────┐ ┌─────▼──────┐ ┌─────▼──────┐
     │    Audio    │ │    ML      │ │    Input   │
     │  Recorder   │ │ Whisper-   │ │  Hotkey-   │
     │  Waveform   │ │ Transcriber│ │  Manager   │
     │  Analyzer   │ │ Model-     │ │  Text-     │
     └──────┬──────┘ │ Manager    │ │  Inserter  │
            │        └─────┬──────┘ └─────┬──────┘
            │              │               │
     ┌──────▼──────────────▼───────────────▼──────┐
     │                 Enhancement                  │
     │              AIEnhancer (rules + Ollama)     │
     └──────────────────────┬──────────────────────┘
                            │
     ┌──────────────────────▼──────────────────────┐
     │                      UI                      │
     │  MenuBarView  RecordingOverlay  SettingsView  │
     │  WaveformView                                 │
     └─────────────────────────────────────────────┘
```

## Data Flow

```
[App Launch]
      │
      ▼
AppDelegate.applicationDidFinishLaunching()
  └── Task { AppState.loadModel() }   ← pre-load, non-blocking
      │
      ▼ (background, while user works in other apps)
WhisperKit loads model into memory (modelState: notLoaded → loading → ready)

[Hotkey Press]
      │
      ▼
HotkeyManager → AppState.startRecording()
  ├── modelState == .ready   → proceed immediately
  └── modelState == .loading → poll-wait until ready (pre-load in progress)
      │
      ▼
AudioRecorder (AVAudioEngine tap)
  ├── waveformBuffer → WaveformAnalyzer → WaveformView (real-time)
  └── audioFile (WAV) written to temp dir
      │
[Hotkey Press again / auto-stop]
      │
      ▼
AppState.stopRecording() → audioURL
      │
      ▼
WhisperTranscriber.transcribe(audioURL) → rawText (async)
      │
      ▼
AIEnhancer.enhance(rawText) → cleanText
      │
      ▼
NSPasteboard ← cleanText, then CGEvent Cmd+V to insert at cursor
      │
      ▼
AppState → ready (click-to-insert) → idle
```

## Key Technical Decisions

### App runs as LSUIElement
No Dock icon. Only Menu Bar. Avoids cluttering the Dock for a background utility.

### AVAudioEngine over AVAudioRecorder
AVAudioEngine provides an installTap() callback for real-time waveform data.
AVAudioRecorder only writes to file — no live buffer access.

### WhisperKit (Core ML) over whisper.cpp
WhisperKit is a Swift-native package, no C++ bridge needed.
Optimized for Apple Silicon via Core ML — faster and easier to integrate.

### Accessibility API as primary text insertion
Clipboard method briefly overwrites user's clipboard — annoying.
AXUIElement can write directly to the focused text field without side effects.
Requires Accessibility permission, which we guide the user through on first use.

### AppState as central state machine
Recording states (idle/recording/processing/error) are complex enough to warrant
a single ObservableObject. All UI subscribes to AppState, no prop drilling.

## Design Constraints

- **Must remain stable:** The hotkey → record → transcribe → insert pipeline. Core UX.
- **Must not be coupled:** Audio module must not import WhisperKit. ML module must not import AVFoundation UI layer.
- **Clear ownership:** AppState owns state transitions. TextInserter owns insertion strategy. WhisperTranscriber owns model lifecycle.

## Entitlements Required

```xml
<!-- microphone access -->
<key>com.apple.security.device.audio-input</key><true/>
<!-- accessibility API -->
<key>com.apple.security.temporary-exception.accessibility</key><true/>
<!-- no sandbox — required for Accessibility API full access -->
<key>com.apple.security.app-sandbox</key><false/>
```

> Note: App Store distribution not possible due to Accessibility entitlements.
> Distribution via notarized DMG.
