import SwiftUI

struct GGPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GGFonts.headline)
                .tightTracking()
                .foregroundStyle(isDestructive ? GGColors.danger : GGColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isDestructive ? GGColors.danger.opacity(0.15) : GGColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct GGSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GGFonts.headline)
                .tightTracking()
                .foregroundStyle(GGColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(GGColors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(GGColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
