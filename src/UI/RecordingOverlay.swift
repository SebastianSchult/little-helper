import AppKit
import SwiftUI

// MARK: - Window

final class RecordingOverlayWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hosting = NSHostingView(rootView: RecordingOverlayView())
        hosting.frame = contentView!.bounds
        hosting.autoresizingMask = [.width, .height]
        contentView = hosting
    }
}

// MARK: - Controller

@MainActor
final class RecordingOverlayController {
    private(set) var window: RecordingOverlayWindow?

    func show() {
        if window == nil { window = RecordingOverlayWindow() }
        guard let window, let screen = NSScreen.main else { return }
        let x = (screen.frame.width - window.frame.width) / 2
        let y = screen.frame.height * 0.25
        window.setFrameOrigin(NSPoint(x: x, y: y))
        window.orderFront(nil)
    }

    func hide() {
        window?.orderOut(nil)
    }
}

// MARK: - View

struct RecordingOverlayView: View {
    @StateObject private var appState = AppState.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)

            Group {
                switch appState.recordingState {
                case .recording:
                    recordingContent
                case .processing:
                    processingContent
                case .ready(let text):
                    readyContent(text: text)
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.easeInOut(duration: 0.2), value: appState.recordingState.description)
    }

    // MARK: Recording

    private var recordingContent: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("Aufnahme läuft  ·  ⌘⇧Space zum Beenden")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Spacer()
            }
            WaveformView(samples: appState.waveformSamples, color: .red)
                .frame(height: 36)
        }
    }

    // MARK: Processing

    private var processingContent: some View {
        HStack(spacing: 10) {
            ProgressView().scaleEffect(0.8)
            Text("Transkribiere…")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(height: 36)
    }

    // MARK: Ready

    private func readyContent(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                    .foregroundStyle(.green)
                    .font(.caption)
                VStack(alignment: .leading, spacing: 1) {
                    Text("In Zwischenablage · Klick in Textfeld zum Einfügen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("oder ⌘V zum manuellen Einfügen")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Button {
                    AppState.shared.dismissResult()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .help("Verwerfen")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
            }
        }
    }
}
