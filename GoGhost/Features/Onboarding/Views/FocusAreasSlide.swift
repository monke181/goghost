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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pick your lanes.")
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)

                    Text("Up to 3. These are your focus areas.")
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textSecondary)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(FocusArea.allCases) { area in
                        AreaCard(
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
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
                .opacity(selectedAreas.isEmpty ? 0.3 : 1)
                .disabled(selectedAreas.isEmpty)
        }
    }
}

private struct AreaCard: View {
    let area: FocusArea
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: area.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? GGColors.accent : GGColors.textSecondary)

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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(isSelected ? GGColors.accentDim : GGColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? GGColors.accent : GGColors.border, lineWidth: isSelected ? 1 : 0.5)
            )
            .opacity(isDisabled ? 0.35 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
