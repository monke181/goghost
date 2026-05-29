import SwiftUI

struct RatingPicker: View {
    @Binding var value: Int
    var max: Int = 10

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(1...max, id: \.self) { i in
                    Button {
                        value = i
                    } label: {
                        Rectangle()
                            .fill(i <= value ? GGColors.accent : GGColors.surface)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .overlay(
                                Rectangle()
                                    .stroke(i <= value ? GGColors.accent : GGColors.border, lineWidth: 1)
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
