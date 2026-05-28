import SwiftUI

struct LaunchSlide: View {
    let runName: String
    let why: String
    let onLaunch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("DAY 1 OF 90")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textSecondary)
                        .tightTracking()

                    Text(runName)
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)
                        .multilineTextAlignment(.center)
                }

                Text(why)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 40)
            }

            Spacer()

            GGPrimaryButton(title: "GO GHOST.", action: onLaunch)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
