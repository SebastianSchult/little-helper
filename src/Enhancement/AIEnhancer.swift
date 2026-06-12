import Foundation

struct AIEnhancer {
    static func enhance(_ text: String) -> String {
        var result = text
        result = removeFillerWords(result)
        result = fixPunctuation(result)
        return result
    }

    // MARK: - Filler word removal

    private static let fillerWords: [String] = [
        // Deutsch
        "äh", "ähm", "ehm", "öh", "öhm", "hm", "hmm", "hmmm",
        "halt", "sozusagen", "quasi", "irgendwie", "naja", "na ja",
        "eigentlich", "gewissermaßen",
        // Englisch
        "uh", "uhh", "um", "umm", "hmm", "like", "you know",
        "basically", "literally", "actually", "right",
    ]

    private static func removeFillerWords(_ text: String) -> String {
        var result = text

        // Longest first — prevents "äh" matching inside "ähm" before "ähm" is tried
        let sorted = fillerWords.sorted { $0.count > $1.count }

        for filler in sorted {
            // Trailing \b ensures no match inside longer words (e.g. "um" ≠ "Umweg")
            let pattern = "(?i)\\b\(NSRegularExpression.escapedPattern(for: filler))\\b[,]?\\s*"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: " ")
            }
        }

        // Collapse multiple spaces left by removals
        result = result.replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Punctuation and capitalisation

    private static func fixPunctuation(_ text: String) -> String {
        guard !text.isEmpty else { return text }

        var result = text

        // Collapse repeated punctuation (e.g. "...", "!!")
        result = result.replacingOccurrences(of: "\\.{2,}", with: ".", options: .regularExpression)
        result = result.replacingOccurrences(of: "!{2,}", with: "!", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\?{2,}", with: "?", options: .regularExpression)

        // Remove space before sentence-ending punctuation
        result = result.replacingOccurrences(of: "\\s+([.,!?])", with: "$1", options: .regularExpression)

        // Capitalise the first letter of each sentence
        result = capitaliseSentences(result)

        // Ensure a sentence-ending punctuation at the end
        let lastChar = result.last
        if let lastChar, ![".", "!", "?"].contains(lastChar) {
            result += "."
        }

        return result
    }

    private static func capitaliseSentences(_ text: String) -> String {
        // Split on sentence boundaries (. ! ?) and capitalise the first word after each
        let sentencePattern = "([.!?]\\s+)([a-zäöüà-ÿ])"
        guard let regex = try? NSRegularExpression(pattern: sentencePattern) else { return text }

        var result = text as NSString
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        // Process in reverse so ranges stay valid
        for match in matches.reversed() {
            let charRange = match.range(at: 2)
            if let swiftRange = Range(charRange, in: text) {
                let upper = text[swiftRange].uppercased()
                result = result.replacingCharacters(in: charRange, with: upper) as NSString
            }
        }

        // Capitalise the very first character
        var finalResult = result as String
        if let first = finalResult.first {
            finalResult = first.uppercased() + finalResult.dropFirst()
        }

        return finalResult
    }
}
