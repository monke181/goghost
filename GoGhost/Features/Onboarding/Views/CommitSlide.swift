import SwiftUI

struct CommitSlide: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("THE TERMS.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)

                VStack(alignment: .leading, spacing: 14) {
                    term("No audience. You build in silence.")
                    term("No off days. The streak doesn't care why.")
                    term("No one is coming. It's on you.")
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "I'M IN.", action: onContinue)
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    private func term(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(GGColors.accent)
                .frame(width: 3, height: 18)
            Text(text)
                .font(GGFonts.body)
                .foregroundStyle(GGColors.textSecondary)
                .lineSpacing(3)
        }
    }
}
