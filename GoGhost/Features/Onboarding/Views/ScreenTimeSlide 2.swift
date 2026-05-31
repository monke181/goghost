import SwiftUI
import FamilyControls

struct ScreenTimeSlide: View {
    let onContinue: () -> Void

    @State private var isRequesting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LOCK IN\nFOR REAL.")
                        .font(GGFonts.title)
                        .foregroundStyle(GGColors.textPrimary)
                        .lineSpacing(2)

                    Text("Ghost Mode can block apps at the OS level.")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    point("Choose exactly which apps get killed during sessions.")
                    point("Enforced by Screen Time — not just a reminder.")
                    point("You pick the apps in Settings after setup.")
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                GGPrimaryButton(
                    title: isRequesting ? "REQUESTING..." : "ENABLE SCREEN TIME"
                ) {
                    guard !isRequesting else { return }
                    isRequesting = true
                    Task {
                        await ScreenTimeManager.shared.requestAuthorization()
                        isRequesting = false
                        onContinue()
                    }
                }

                Button(action: onContinue) {
                    Text("SKIP FOR NOW")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 56)
        }
    }

    private func point(_ text: String) -> some View {
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
