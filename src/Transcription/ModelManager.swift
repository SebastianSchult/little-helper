import Foundation

@MainActor
final class ModelManager: ObservableObject {
    static let shared = ModelManager()

    static let availableModels: [(id: String, label: String)] = [
        ("openai_whisper-tiny",   "Tiny   (~150 MB)"),
        ("openai_whisper-base",   "Base   (~280 MB)"),
        ("openai_whisper-small",  "Small  (~500 MB)"),
        ("openai_whisper-medium", "Medium (~1.5 GB)"),
    ]

    // Progress per model ID while downloading/loading (nil = not active)
    @Published var downloadProgress: [String: Double] = [:]

    private init() {}

    func isDownloading(_ model: String) -> Bool {
        downloadProgress[model] != nil
    }

    func progress(for model: String) -> Double {
        downloadProgress[model] ?? 0
    }

    func setProgress(_ value: Double?, for model: String) {
        downloadProgress[model] = value
    }
}
