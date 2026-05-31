import SwiftUI

struct SystemSlide: View {
    let onContinue: () -> Void

    private let moves: [(String, String, String)] = [
        ("01", "CHECK IN", "Set the target at sunrise. Log the truth at night."),
        ("02", "LOCK IN", "Deep sessions with the phone dead. No noise."),
        ("03", "STACK DAYS", "Every day scored. The streak is the receipt.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("THE SYSTEM.")
                        .font(GGFonts.title)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("Three moves a day. That's the whole game.")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 20) {
                    ForEach(moves, id: \.0) { move in
                        HStack(alignment: .top, spacing: 14) {
                            Text(move.0)
                                .font(GGFonts.counterSmall)
                                .foregroundStyle(GGColors.textTertiary)
                                .bebasTracking()

                            VStack(alignment: .leading, spacing: 3) {
                                Text(move.1)
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.textPrimary)
                                    .tightTracking()
                                Text(move.2)
                                    .font(GGFonts.caption)
                                    .foregroundStyle(GGColors.textTertiary)
                                    .lineSpacing(2)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "CONTINUE", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
