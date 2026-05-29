import SwiftUI

struct LaunchSlide: View {
    let runName: String
    let why: String
    let onLaunch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Text("DAY 1 OF 90")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()

                Text(runName.uppercased())
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)

                Rectangle().fill(GGColors.border).frame(height: 1)

                Text(why)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .lineLimit(5)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "GO GHOST.", action: onLaunch)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
