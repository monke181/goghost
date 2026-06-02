import SwiftUI
import SwiftData

enum LogSection: Hashable {
    case journal
    case reflections
}

struct LogView: View {
    @State private var section: LogSection = .journal

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("LOG")
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 64)
                .padding(.bottom, 20)

                LogSegmentedControl(section: $section)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Rectangle().fill(GGColors.border).frame(height: 1)

                // Content
                Group {
                    switch section {
                    case .journal:     JournalSectionView()
                    case .reflections: ReflectionsSectionView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

private struct LogSegmentedControl: View {
    @Binding var section: LogSection

    private let items: [(section: LogSection, label: String)] = [
        (.journal, "JOURNAL"),
        (.reflections, "REFLECTIONS")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.section) { item in
                let isActive = section == item.section
                Button {
                    withAnimation(GGAnimations.standard) { section = item.section }
                } label: {
                    VStack(spacing: 10) {
                        Text(item.label)
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(isActive ? GGColors.textPrimary : GGColors.textTertiary)
                        Rectangle()
                            .fill(isActive ? GGColors.accent : GGColors.border)
                            .frame(height: isActive ? 2 : 1)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
