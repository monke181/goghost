import SwiftUI

struct GGProgressRing: View {
    let progress: Double   // 0.0 – 1.0
    let dayNumber: Int
    let totalDays: Int
    var size: CGFloat = 220
    var lineWidth: CGFloat = 6

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(GGColors.border, lineWidth: lineWidth)

            // Fill
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    GGColors.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(GGFonts.counter)
                    .foregroundStyle(GGColors.textPrimary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("OF \(totalDays)")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textSecondary)
                    .tightTracking()
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(GGAnimations.ringFill) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(GGAnimations.standard) {
                animatedProgress = newValue
            }
        }
    }
}
