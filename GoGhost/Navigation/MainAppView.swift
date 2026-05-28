import SwiftUI

enum AppTab {
    case dashboard
    case ghostMode
    case settings
}

struct MainAppView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .dashboard:
                    NavigationStack {
                        DashboardView()
                    }
                case .ghostMode:
                    NavigationStack {
                        GhostModeView()
                    }
                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GGBottomNav(selectedTab: $selectedTab)
        }
        .background(GGColors.background)
        .ignoresSafeArea()
    }
}
