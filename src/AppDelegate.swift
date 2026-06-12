import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        HotkeyManager.shared.setup()
        Task { await AppState.shared.loadModel() }

        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            requestAccessibilityPermissionIfNeeded()
        } else {
            Task { @MainActor in OnboardingController.shared.show() }
        }
    }

    private func requestAccessibilityPermissionIfNeeded() {
        guard !AXIsProcessTrusted() else { return }
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
