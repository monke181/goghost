import SwiftUI

struct WelcomeSlide: View {
    let onBegin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("90")
                    .font(GGFonts.hero)
                    .foregroundStyle(GGColors.textPrimary)

                Text("DAYS.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)

                Spacer().frame(height: 16)

                Text("What happens when you\ngo ghost?")
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "BEGIN", action: onBegin)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
