import SwiftUI

struct RootRouter: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainAppView()
        } else {
            OnboardingContainerView()
        }
    }
}
