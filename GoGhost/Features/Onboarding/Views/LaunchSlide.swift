import SwiftUI

struct LaunchSlide: View {
    let why: String
    let focusAreas: [String]
    let onLaunch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Text("DAY 1 OF 90")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()

                Text("GO GHOST.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)

                Rectangle().fill(GGColors.border).frame(height: 1)

                Text(why)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .lineLimit(5)
                    .lineSpacing(4)

                if !focusAreas.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(focusAreas, id: \.self) { area in
                            Text(area.uppercased())
                                .font(GGFonts.label)
                                .tightTracking()
                                .foregroundStyle(GGColors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                        }
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "LOCK IN.", action: onLaunch)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
