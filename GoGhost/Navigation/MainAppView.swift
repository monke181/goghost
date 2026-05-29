import SwiftUI

enum AppTab {
    case dashboard
    case ghostMode
    case settings
}

struct MainAppView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                switch selectedTab {
                case .dashboard:
                    NavigationStack { DashboardView() }
                case .ghostMode:
                    NavigationStack { GhostModeView() }
                case .settings:
                    NavigationStack { SettingsView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar — flat, no capsule
            GGBottomNav(selectedTab: $selectedTab)
                .background(GGColors.background)
        }
        .background(GGColors.background)
        .ignoresSafeArea(edges: .top)
    }
}
