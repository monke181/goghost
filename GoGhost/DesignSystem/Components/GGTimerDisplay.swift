import SwiftUI

struct GGTimerDisplay: View {
    let remainingSeconds: Int

    private var minutes: Int { remainingSeconds / 60 }
    private var seconds: Int { remainingSeconds % 60 }

    var body: some View {
        Text(String(format: "%02d:%02d", minutes, seconds))
            .font(GGFonts.counter)
            .foregroundStyle(GGColors.textPrimary)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .monospacedDigit()
    }
}
