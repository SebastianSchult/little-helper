import SwiftUI

struct MenuBarView: View {
    @StateObject private var appState = AppState.shared
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: stateIcon)
                    .foregroundColor(stateColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(stateLabel)
                        .font(.headline)
                    if case .loading = appState.modelState {
                        Text("Modell wird geladen…")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if !appState.lastTranscription.isEmpty {
                        Text(appState.lastTranscription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("⌘⇧Space zum Aufnehmen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            Divider()

            Button(appState.isRecording ? "⏹ Stop" : "🎙 Aufnehmen") {
                Task { await AppState.shared.toggleRecording() }
            }
            .frame(maxWidth: .infinity)

            Divider()

            HStack {
                Button("Settings") {
                    NSApp.activate(ignoringOtherApps: true)
                    openSettings()
                }
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 260)
    }

    private var stateIcon: String {
        switch appState.recordingState {
        case .idle:        return "mic"
        case .recording:   return "mic.fill"
        case .processing:  return "waveform"
        case .ready:       return "text.bubble"
        case .error:       return "exclamationmark.triangle"
        }
    }

    private var stateColor: Color {
        switch appState.recordingState {
        case .idle:        return .secondary
        case .recording:   return .red
        case .processing:  return .orange
        case .ready:       return .green
        case .error:       return .red
        }
    }

    private var stateLabel: String {
        switch appState.recordingState {
        case .idle:             return "little helper"
        case .recording:        return "Aufnahme läuft…"
        case .processing:       return "Transkribiere…"
        case .ready:            return "Klick zum Einfügen"
        case .error(let msg):   return "Fehler: \(msg)"
        }
    }
}
