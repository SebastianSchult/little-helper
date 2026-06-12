import SwiftUI

@main
struct LittleHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            MenuBarIconView(state: appState.recordingState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}

private struct MenuBarIconView: View {
    let state: RecordingState

    var body: some View {
        Image(systemName: iconName)
            .foregroundStyle(iconColor)
            .symbolEffect(.pulse, isActive: isActive)
    }

    private var iconName: String {
        switch state {
        case .idle:        return "mic"
        case .recording:   return "mic.fill"
        case .processing:  return "waveform"
        case .ready:       return "text.bubble"
        case .error:       return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch state {
        case .idle:        return .primary
        case .recording:   return .red
        case .processing:  return .orange
        case .ready:       return .green
        case .error:       return .red
        }
    }

    private var isActive: Bool {
        switch state {
        case .recording, .processing: return true
        default: return false
        }
    }
}
