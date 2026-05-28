import SwiftUI

struct WelcomeSlide: View {
    let onBegin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text("90 DAYS.")
                    .font(GGFonts.counter)
                    .foregroundStyle(GGColors.textPrimary)

                Text("What happens when you go ghost?")
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            GGPrimaryButton(title: "BEGIN", action: onBegin)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
