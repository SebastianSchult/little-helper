import AVFoundation

@MainActor
final class AudioRecorder {
    private var engine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var currentURL: URL?

    var onWaveformUpdate: (([Float]) -> Void)?

    func startRecording() async throws {
        let engine = AVAudioEngine()
        self.engine = engine

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")
        currentURL = url

        let file = try AVAudioFile(forWriting: url, settings: inputFormat.settings)
        audioFile = file

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            try? file.write(from: buffer)
            let samples = WaveformAnalyzer.analyze(buffer)
            DispatchQueue.main.async {
                self?.onWaveformUpdate?(samples)
            }
        }

        try engine.start()
    }

    func stopRecording() -> URL? {
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        audioFile = nil
        return currentURL
    }
}
