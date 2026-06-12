import SwiftUI

struct WaveformView: View {
    var samples: [Float]
    var color: Color = .red

    var body: some View {
        Canvas { context, size in
            guard !samples.isEmpty else { return }

            let count = samples.count
            let totalSpacing = CGFloat(count - 1) * 3
            let barWidth = (size.width - totalSpacing) / CGFloat(count)
            let centerY = size.height / 2
            let maxBarHalf = size.height / 2 - 1

            for (i, sample) in samples.enumerated() {
                let x = CGFloat(i) * (barWidth + 3)
                let half = max(2, CGFloat(sample) * maxBarHalf * 5).clamped(to: 2...maxBarHalf)
                let rect = CGRect(x: x, y: centerY - half, width: barWidth, height: half * 2)

                let alpha = 0.5 + Double(sample) * 2.5
                context.fill(
                    Path(roundedRect: rect, cornerRadius: barWidth / 2),
                    with: .color(color.opacity(alpha.clamped(to: 0.4...1.0)))
                )
            }
        }
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
