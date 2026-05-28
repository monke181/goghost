import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @State private var vm = OnboardingViewModel()
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            TabView(selection: $vm.currentSlide) {
                WelcomeSlide(onBegin: vm.advance).tag(0)
                WhySlide(why: $vm.why, onContinue: vm.advance).tag(1)
                NameRunSlide(runName: $vm.runName, suggestions: vm.nameSuggestions, onContinue: vm.advance).tag(2)
                FocusAreasSlide(selectedAreas: vm.selectedAreas, onToggle: vm.toggleArea, onContinue: vm.advance).tag(3)
                LaunchSlide(runName: vm.runName, why: vm.why) {
                    vm.commitRun(context: context)
                    hasCompletedOnboarding = true
                }.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: vm.currentSlide)
        }
    }
}
