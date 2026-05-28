import SwiftUI

struct RatingPicker: View {
    @Binding var value: Int
    var max: Int = 10

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(1...max, id: \.self) { i in
                    Button {
                        value = i
                    } label: {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(i <= value ? GGColors.accent : GGColors.surfaceElevated)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(i <= value ? GGColors.accent : GGColors.border, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("1")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)
                Spacer()
                Text("\(value) / \(max)")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textSecondary)
                Spacer()
                Text("\(max)")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)
            }
        }
    }
}
