import AVFoundation

struct WaveformAnalyzer {
    static func analyze(_ buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData?[0] else { return [] }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return [] }

        let binCount = 40
        let binSize = max(1, frameCount / binCount)

        return (0..<binCount).map { bin in
            let start = bin * binSize
            let end = min(start + binSize, frameCount)
            var sum: Float = 0
            for i in start..<end {
                sum += abs(channelData[i])
            }
            return sum / Float(end - start)
        }
    }
}
