import SwiftUI

struct GGPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GGFonts.label)
                .tightTracking()
                .foregroundStyle(isDestructive ? GGColors.danger : GGColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isDestructive ? .clear : GGColors.textPrimary)
                .overlay(
                    Rectangle()
                        .stroke(isDestructive ? GGColors.danger : GGColors.textPrimary, lineWidth: 1)
                )
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
                .font(GGFonts.label)
                .tightTracking()
                .foregroundStyle(GGColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.clear)
                .overlay(
                    Rectangle()
                        .stroke(GGColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
