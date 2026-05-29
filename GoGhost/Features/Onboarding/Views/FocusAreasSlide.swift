import SwiftUI

struct FocusAreasSlide: View {
    let selectedAreas: Set<String>
    let onToggle: (String) -> Void
    let onContinue: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PICK YOUR LANES.")
                        .font(GGFonts.title)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("Up to 3. These are your focus areas.")
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textSecondary)
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(FocusArea.allCases) { area in
                        AreaRow(
                            area: area,
                            isSelected: selectedAreas.contains(area.rawValue),
                            isDisabled: !selectedAreas.contains(area.rawValue) && selectedAreas.count >= 3
                        ) {
                            onToggle(area.rawValue)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            GGPrimaryButton(title: "CONTINUE", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 56)
                .opacity(selectedAreas.isEmpty ? 0.3 : 1)
                .disabled(selectedAreas.isEmpty)
        }
    }
}

private struct AreaRow: View {
    let area: FocusArea
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(isSelected ? GGColors.accent : GGColors.border)
                    .frame(width: 3, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(area.rawValue.uppercased())
                        .font(GGFonts.label)
                        .foregroundStyle(isSelected ? GGColors.textPrimary : GGColors.textSecondary)
                        .tightTracking()
                    Text(area.tagline)
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(GGColors.surface)
            .overlay(
                Rectangle()
                    .stroke(isSelected ? GGColors.accent : GGColors.border, lineWidth: 1)
            )
            .opacity(isDisabled ? 0.3 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
