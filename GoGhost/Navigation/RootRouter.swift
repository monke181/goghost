import SwiftUI

struct RootRouter: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(SubscriptionManager.self) private var subscriptions

    var body: some View {
        #if DEBUG
        // Launch with `-ggBypassGate 1` to skip onboarding + paywall for testing.
        if ProcessInfo.processInfo.arguments.contains("-ggBypassGate") {
            MainAppView()
        } else {
            gatedBody
        }
        #else
        gatedBody
        #endif
    }

    @ViewBuilder
    private var gatedBody: some View {
        if !hasCompletedOnboarding {
            OnboardingContainerView()
        } else if subscriptions.isSubscribed {
            MainAppView()
        } else if !subscriptions.hasResolvedInitialStatus {
            // Brief moment between launch and the first customer-info emission.
            // Show a neutral splash rather than flashing the paywall or the app.
            loadingSplash
        } else {
            PaywallView()
        }
    }

    private var loadingSplash: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()
            ProgressView().tint(GGColors.textSecondary)
        }
    }
}
