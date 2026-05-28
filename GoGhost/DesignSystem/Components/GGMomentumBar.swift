import SwiftUI

struct GGMomentumBar: View {
    let scores: [Int]   // last 7 days, oldest first, 0 = no entry

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(scores.enumerated()), id: \.offset) { index, score in
                segment(score: score, isToday: index == scores.count - 1)
            }
        }
    }

    @ViewBuilder
    private func segment(score: Int, isToday: Bool) -> some View {
        Capsule()
            .fill(segmentColor(score: score, isToday: isToday))
            .frame(width: 8, height: 32)
            .overlay {
                if isToday && score == 0 {
                    Capsule()
                        .stroke(GGColors.border, lineWidth: 1)
                }
            }
    }

    private func segmentColor(score: Int, isToday: Bool) -> Color {
        if score == 0 { return isToday ? GGColors.textTertiary : GGColors.textTertiary.opacity(0.4) }
        if score >= 80 { return GGColors.accent }
        if score >= 50 { return GGColors.accent.opacity(0.5) }
        return GGColors.danger.opacity(0.6)
    }
}
