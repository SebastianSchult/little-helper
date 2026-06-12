import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording", default: .init(.space, modifiers: [.command, .shift]))
}

@MainActor
final class HotkeyManager {
    static let shared = HotkeyManager()

    private init() {}

    func setup() {
        KeyboardShortcuts.onKeyDown(for: .toggleRecording) {
            print("[HotkeyManager] hotkey fired")
            Task { @MainActor in
                await AppState.shared.toggleRecording()
            }
        }
        print("[HotkeyManager] setup done, shortcut: \(String(describing: KeyboardShortcuts.getShortcut(for: .toggleRecording)))")
    }
}
