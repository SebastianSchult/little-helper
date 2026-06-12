import Foundation
import WhisperKit

final class WhisperTranscriber {
    private var pipe: WhisperKit?

    func prepare(model: String) async throws {
        pipe = try await WhisperKit(model: model)
    }

    func transcribe(audioURL: URL, language: String) async throws -> String {
        guard let pipe else { throw TranscriptionError.notInitialized }

        let options = DecodingOptions(task: .transcribe, language: language)
        let results = try await pipe.transcribe(audioPath: audioURL.path, decodeOptions: options)
        return results.compactMap { $0.text }.joined(separator: " ")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    enum TranscriptionError: LocalizedError {
        case notInitialized
        var errorDescription: String? { "Modell nicht geladen" }
    }
}
