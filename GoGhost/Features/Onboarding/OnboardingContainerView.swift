import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @State private var vm = OnboardingViewModel()
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                slide
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // Back chevron + progress bar. Back is hidden on the first slide.
    private var topBar: some View {
        HStack(spacing: 16) {
            Button(action: vm.back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(GGColors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .opacity(vm.step == .welcome ? 0 : 1)
            .disabled(vm.step == .welcome)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(GGColors.border)
                        .frame(height: 2)
                    Rectangle()
                        .fill(GGColors.textPrimary)
                        .frame(width: geo.size.width * vm.progress, height: 2)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 32)
        .padding(.top, 16)
    }

    // Single slide shown at a time. Directional move transition replaces the
    // old TabView page style, which left slides stranded mid-drag.
    private var slide: some View {
        Group {
            switch vm.step {
            case .welcome:
                WelcomeSlide(onBegin: vm.advance)
            case .system:
                SystemSlide(onContinue: vm.advance)
            case .why:
                WhySlide(why: $vm.why, onContinue: vm.advance)
            case .focus:
                FocusAreasSlide(
                    selectedAreas: vm.selectedAreas,
                    onToggle: vm.toggleArea,
                    onContinue: vm.advance
                )
            case .commit:
                CommitSlide(onContinue: vm.advance)
            case .launch:
                LaunchSlide(why: vm.why, focusAreas: Array(vm.selectedAreas)) {
                    vm.commitRun(context: context)
                    hasCompletedOnboarding = true
                }
            }
        }
        .id(vm.step)
        .transition(.asymmetric(
            insertion: .move(edge: vm.direction >= 0 ? .trailing : .leading),
            removal: .move(edge: vm.direction >= 0 ? .leading : .trailing)
        ))
    }
}
