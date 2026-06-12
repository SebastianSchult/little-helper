import Foundation
import AVFoundation
import AppKit
import OSLog

private let logger = Logger(subsystem: "com.sebastianschult.little-helper", category: "AppState")

enum RecordingState: CustomStringConvertible {
    case idle, recording, processing
    case ready(String)   // transcription done, waiting for user to pick insertion point
    case error(String)
    var description: String {
        switch self {
        case .idle:          return "idle"
        case .recording:     return "recording"
        case .processing:    return "processing"
        case .ready(let t):  return "ready(\(t.prefix(20))…)"
        case .error(let m):  return "error(\(m))"
        }
    }
}

enum ModelState: CustomStringConvertible {
    case notLoaded, loading, ready
    case failed(String)
    var description: String {
        switch self {
        case .notLoaded:     return "notLoaded"
        case .loading:       return "loading"
        case .ready:         return "ready"
        case .failed(let m): return "failed(\(m))"
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var recordingState: RecordingState = .idle
    @Published var modelState: ModelState = .notLoaded
    @Published var lastTranscription: String = ""
    @Published var waveformSamples: [Float] = []

    @Published var selectedModel: String = UserDefaults.standard.string(forKey: "selectedModel") ?? "openai_whisper-tiny" {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
            modelState = .notLoaded
            Task { await loadModel() }
        }
    }

    @Published var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "de" {
        didSet { UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage") }
    }

    @Published var enhancementEnabled: Bool = UserDefaults.standard.bool(forKey: "enhancementEnabled") {
        didSet { UserDefaults.standard.set(enhancementEnabled, forKey: "enhancementEnabled") }
    }

    @Published var ollamaEnabled: Bool = UserDefaults.standard.bool(forKey: "ollamaEnabled") {
        didSet { UserDefaults.standard.set(ollamaEnabled, forKey: "ollamaEnabled") }
    }

    @Published var ollamaModel: String = UserDefaults.standard.string(forKey: "ollamaModel") ?? OllamaEnhancer.defaultModel {
        didSet { UserDefaults.standard.set(ollamaModel, forKey: "ollamaModel") }
    }

    let overlay = RecordingOverlayController()

    private let recorder = AudioRecorder()
    private let transcriber = WhisperTranscriber()
    private var clickMonitor: Any?

    var isRecording: Bool {
        if case .recording = recordingState { return true }
        return false
    }

    var isProcessing: Bool {
        if case .processing = recordingState { return true }
        return false
    }

    func toggleRecording() async {
        logger.info("[AppState] toggleRecording called, state: \(self.recordingState)")
        switch recordingState {
        case .idle:
            await startRecording()
        case .recording:
            await stopAndTranscribe()
        case .ready:
            dismissResult()
        default:
            break
        }
    }

    func dismissResult() {
        stopClickMonitor()
        recordingState = .idle
        overlay.hide()
    }

    // MARK: - Private

    private func startRecording() async {
        let granted = await requestMicrophonePermission()
        logger.info("[AppState] mic permission granted: \(granted)")
        guard granted else {
            recordingState = .error("Mikrofon-Zugriff verweigert")
            return
        }

        switch modelState {
        case .notLoaded:
            logger.info("[AppState] loading model on demand: \(self.selectedModel)")
            await loadModel()
        case .loading:
            logger.info("[AppState] waiting for model pre-load to complete")
            while case .loading = modelState {
                try? await Task.sleep(for: .milliseconds(200))
            }
        default:
            break
        }

        if case .failed(let msg) = modelState {
            recordingState = .error("Modell: \(msg)")
            return
        }
        guard case .ready = modelState else {
            recordingState = .error("Modell nicht bereit")
            return
        }

        do {
            recorder.onWaveformUpdate = { [weak self] samples in
                self?.waveformSamples = samples
            }
            try await recorder.startRecording()
            recordingState = .recording
            overlay.show()
            logger.info("[AppState] recording started")
        } catch {
            logger.info("[AppState] recording error: \(error)")
            recordingState = .error(error.localizedDescription)
        }
    }

    private func stopAndTranscribe() async {
        guard let audioURL = recorder.stopRecording() else {
            recordingState = .idle
            overlay.hide()
            return
        }
        waveformSamples = []
        recordingState = .processing

        do {
            let raw = try await transcriber.transcribe(audioURL: audioURL, language: selectedLanguage)
            var text = enhancementEnabled ? AIEnhancer.enhance(raw) : raw
            if ollamaEnabled {
                text = (try? await OllamaEnhancer.enhance(text, model: ollamaModel)) ?? text
            }
            lastTranscription = text
            try? FileManager.default.removeItem(at: audioURL)

            // Enter ready state — let user click where they want to insert
            recordingState = .ready(text)
            startClickMonitor(text: text)
        } catch {
            logger.info("[AppState] transcription error: \(error)")
            recordingState = .error(error.localizedDescription)
            overlay.hide()
        }
    }

    // MARK: - Click-to-insert monitor

    private func startClickMonitor(text: String) {
        // Pre-load clipboard so the text is ready immediately when user pastes
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            guard let self else { return }
            let clickLocation = NSEvent.mouseLocation

            // Ignore clicks on our own overlay
            if let win = self.overlay.window, win.frame.contains(clickLocation) { return }

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.stopClickMonitor()
                // Wait for the clicked element to receive focus
                try? await Task.sleep(for: .milliseconds(120))
                // Simulate ⌘V — works in every text field without needing AX element lookup
                self.postCmdV()
                // Brief pause so paste lands before we change state
                try? await Task.sleep(for: .milliseconds(200))
                self.recordingState = .idle
                self.overlay.hide()
            }
        }
    }

    private func stopClickMonitor() {
        if let m = clickMonitor { NSEvent.removeMonitor(m) }
        clickMonitor = nil
    }

    private func postCmdV() {
        let src = CGEventSource(stateID: .hidSystemState)
        let vKey: CGKeyCode = 0x09
        let down = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: true)
        let up   = CGEvent(keyboardEventSource: src, virtualKey: vKey, keyDown: false)
        down?.flags = .maskCommand
        up?.flags   = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    // MARK: - Model

    func loadModel() async {
        modelState = .loading
        do {
            try await transcriber.prepare(model: selectedModel)
            modelState = .ready
            logger.info("[AppState] model ready")
        } catch {
            logger.info("[AppState] model load failed: \(error)")
            modelState = .failed(error.localizedDescription)
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
