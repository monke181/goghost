import SwiftUI

struct GGBottomNav: View {
    @Binding var selectedTab: AppTab

    private let tabs: [(tab: AppTab, icon: String)] = [
        (.dashboard,  "square.grid.2x2"),
        (.ghostMode,  "moon.fill"),
        (.settings,   "gearshape")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tab.hashValue) { item in
                Button {
                    selectedTab = item.tab
                } label: {
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: selectedTab == item.tab ? .bold : .regular))
                        .foregroundStyle(selectedTab == item.tab ? GGColors.accent : GGColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(GGColors.border, lineWidth: 0.5)
        )
        .padding(.horizontal, 48)
        .padding(.bottom, 24)
    }
}

extension AppTab: Hashable {}
