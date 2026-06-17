import SwiftUI
import AVFoundation

// MARK: - Window

private final class OnboardingWindow: NSWindow {
    init(rootView: some View) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        title = "little helper einrichten"
        isReleasedWhenClosed = false
        contentView = NSHostingView(rootView: rootView)
        center()
    }
}

// MARK: - Controller

@MainActor
final class OnboardingController {
    static let shared = OnboardingController()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let view = OnboardingView {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                self.window?.close()
                self.window = nil
            }
            window = OnboardingWindow(rootView: view)
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - View

struct OnboardingView: View {
    enum Step: String { case welcome, accessibility, microphone, done }

    @State private var step: Step = .welcome
    @State private var accessibilityGranted: Bool = AXIsProcessTrusted()
    @State private var micGranted: Bool = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized

    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 32)
            stepContent
                .animation(.easeInOut(duration: 0.25), value: step.rawValue)
            Spacer(minLength: 24)
            progressDots
                .padding(.bottom, 16)
                .opacity(step == .welcome || step == .done ? 0 : 1)
            navigationRow
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
        }
        .frame(width: 480, height: 420)
        .task(id: step) {
            guard step == .accessibility else { return }
            while true {
                let trusted = AXIsProcessTrusted()
                if trusted { accessibilityGranted = true; break }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            if step == .accessibility { accessibilityGranted = AXIsProcessTrusted() }
            if step == .microphone    { micGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized }
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            OnboardingCard(
                icon: "mic.fill",
                iconColor: .accentColor,
                title: "Willkommen bei\nlittle helper",
                message: "little helper transkribiert deine Sprache lokal auf deinem Mac — offline, schnell, ohne Cloud.\n\nIn zwei Schritten einrichten."
            )
        case .accessibility:
            OnboardingCard(
                icon: "accessibility",
                iconColor: accessibilityGranted ? .green : .orange,
                title: "Bedienungshilfen",
                message: "Damit little helper Text per ⌘V einfügen kann, braucht die App Zugriff auf die Bedienungshilfen.\n\nÖffne System Settings und aktiviere little helper unter Datenschutz → Bedienungshilfen.",
                badge: accessibilityGranted ? "Erteilt" : nil,
                actionLabel: accessibilityGranted ? nil : "System Settings öffnen",
                actionHandler: openAccessibilitySettings
            )
        case .microphone:
            OnboardingCard(
                icon: "mic.fill",
                iconColor: micGranted ? .green : .red,
                title: "Mikrofon",
                message: "little helper benötigt Zugriff auf dein Mikrofon um Sprachaufnahmen zu machen.\n\nDie Berechtigung kann jederzeit in den Systemeinstellungen widerrufen werden.",
                badge: micGranted ? "Erteilt" : nil,
                actionLabel: micGranted ? nil : "Mikrofon-Zugriff erlauben",
                actionHandler: requestMicrophone
            )
        case .done:
            OnboardingCard(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                title: "Alles bereit",
                message: "Drücke ⌘⇧Space um eine Aufnahme zu starten.\nDas Icon in der Menu Bar zeigt den Status."
            )
        }
    }

    // MARK: - Progress dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            progressDot(active: step == .accessibility || step == .microphone)
            progressDot(active: step == .microphone)
        }
    }

    private func progressDot(active: Bool) -> some View {
        Circle()
            .fill(active ? Color.accentColor : Color.secondary.opacity(0.3))
            .frame(width: 7, height: 7)
            .animation(.easeInOut(duration: 0.2), value: active)
    }

    // MARK: - Navigation

    private var navigationRow: some View {
        HStack {
            if step == .accessibility || step == .microphone {
                Button("Zurück") { back() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(nextLabel) { next() }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
        }
    }

    private var nextLabel: String {
        switch step {
        case .welcome:        return "Einrichten"
        case .accessibility:  return "Weiter"
        case .microphone:     return "Weiter"
        case .done:           return "Loslegen"
        }
    }

    private var canProceed: Bool {
        switch step {
        case .welcome, .done:  return true
        case .accessibility:   return accessibilityGranted
        case .microphone:      return micGranted
        }
    }

    private func next() {
        switch step {
        case .welcome:        step = .accessibility
        case .accessibility:  step = .microphone
        case .microphone:     step = .done
        case .done:           onComplete()
        }
    }

    private func back() {
        switch step {
        case .accessibility:  step = .welcome
        case .microphone:     step = .accessibility
        default:              break
        }
    }

    // MARK: - Permission actions

    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func requestMicrophone() {
        Task {
            micGranted = await AVCaptureDevice.requestAccess(for: .audio)
        }
    }
}

// MARK: - Card

private struct OnboardingCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    var badge: String? = nil
    var actionLabel: String? = nil
    var actionHandler: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundStyle(iconColor)
                    .symbolEffect(.pulse, isActive: iconColor == .orange)
                if let badge {
                    Label(badge, systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                        .offset(x: 36, y: -8)
                }
            }
            .frame(height: 72)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 340)

            if let label = actionLabel {
                Button(label) { actionHandler?() }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 48)
    }
}
