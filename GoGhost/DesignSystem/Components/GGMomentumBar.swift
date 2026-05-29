import SwiftUI

struct GGMomentumBar: View {
    let scores: [Int]   // last 7 days, oldest first, 0 = no entry

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(scores.enumerated()), id: \.offset) { index, score in
                Rectangle()
                    .fill(segmentColor(score: score, isToday: index == scores.count - 1))
                    .frame(width: 10, height: 28)
                    .overlay(
                        Rectangle()
                            .stroke(GGColors.border, lineWidth: 0.5)
                    )
            }
        }
    }

    private func segmentColor(score: Int, isToday: Bool) -> Color {
        if score == 0 { return isToday ? GGColors.surface : GGColors.background }
        if score >= 80 { return GGColors.accent }
        if score >= 50 { return GGColors.accent.opacity(0.45) }
        return GGColors.danger.opacity(0.5)
    }
}
