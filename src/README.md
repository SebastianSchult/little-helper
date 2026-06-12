# src/

Swift-Quellcode für little helper.

## Struktur

```
src/
├── LittleHelperApp.swift        ← @main App entry point, LSUIElement
├── AppDelegate.swift            ← NSStatusItem, Menu Bar lifecycle
├── AppState.swift               ← ObservableObject, State Machine
│
├── Audio/
│   ├── AudioRecorder.swift      ← AVAudioEngine, Aufnahme + Waveform-Tap
│   └── WaveformAnalyzer.swift   ← Buffer → Float-Array für UI
│
├── Transcription/
│   ├── WhisperTranscriber.swift ← WhisperKit wrapper
│   └── ModelManager.swift       ← Model download, cache, selection
│
├── Input/
│   ├── HotkeyManager.swift      ← Globaler Hotkey (KeyboardShortcuts)
│   └── TextInserter.swift       ← AXUIElement + Clipboard Fallback
│
├── Enhancement/
│   └── AIEnhancer.swift         ← Regelbasiert + Ollama (Phase 4)
│
└── UI/
    ├── RecordingOverlay.swift   ← Floating NSPanel
    ├── WaveformView.swift       ← Canvas Waveform
    ├── MenuBarView.swift        ← Status Bar Menu
    └── SettingsView.swift       ← Settings Panel
```

## Conventions

- Alle UI-Code-Pfade laufen auf `@MainActor`
- Business-Logik in dedizierten Klassen/Actors, nie in View-Bodies
- `async/await` überall, keine Completion-Handler
- Fehler mit `throws` propagieren, nie stumm schlucken
- Änderungen: ~300 LOC pro reviewbarem Chunk
