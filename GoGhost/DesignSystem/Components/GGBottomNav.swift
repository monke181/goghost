import SwiftUI

struct GGBottomNav: View {
    @Binding var selectedTab: AppTab

    private let tabs: [(tab: AppTab, label: String)] = [
        (.dashboard, "HOME"),
        (.ghostMode, "GHOST"),
        (.settings,  "CONFIG")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(GGColors.border)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(tabs, id: \.tab.hashValue) { item in
                    Button {
                        selectedTab = item.tab
                    } label: {
                        Text(item.label)
                            .font(GGFonts.label)
                            .tightTracking()
                            .foregroundStyle(selectedTab == item.tab ? GGColors.textPrimary : GGColors.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(GGColors.background)
        }
    }
}

extension AppTab: Hashable {}
