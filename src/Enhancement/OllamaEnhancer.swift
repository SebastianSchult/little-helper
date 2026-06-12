import Foundation

struct OllamaEnhancer {
    static let defaultModel = "llama3.2:3b"
    private static let baseURL = "http://localhost:11434"

    static func enhance(_ text: String, model: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/generate")!
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "prompt": prompt(for: text),
            "stream": false,
            "options": ["temperature": 0.1],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw OllamaError.badResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["response"] as? String else {
            throw OllamaError.invalidResponse
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Fetch installed models from the local Ollama daemon
    static func availableModels() async -> [String] {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return [] }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let models = json["models"] as? [[String: Any]] else { return [] }
        return models.compactMap { $0["name"] as? String }.sorted()
    }

    private static func prompt(for text: String) -> String {
        """
        Correct grammar, punctuation, and sentence structure. \
        CRITICAL: Respond in the EXACT SAME language as the input. Never translate. \
        Return ONLY the corrected text, nothing else.

        Input: \(text)
        Output:
        """
    }

    enum OllamaError: LocalizedError {
        case badResponse, invalidResponse
        var errorDescription: String? {
            switch self {
            case .badResponse:    return "Ollama: ungültige HTTP-Antwort"
            case .invalidResponse: return "Ollama: unerwartetes Antwortformat"
            }
        }
    }
}
