import SwiftUI
import SwiftData

struct GhostModeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Query(filter: #Predicate<Run> { $0.isActive }) private var runs: [Run]

    @State private var vm = GhostModeViewModel()

    private var run: Run? { runs.first }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if vm.justCompleted {
                completionScreen
                    .transition(.opacity)
            } else {
                mainScreen
            }
        }
        .navigationBarHidden(true)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { vm.handleBackground() }
            if phase == .active { vm.handleForeground() }
        }
    }

    // MARK: — Main screen

    private var mainScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            // Label
            Text("GHOST MODE")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()

            Spacer()

            // Timer
            GGTimerDisplay(remainingSeconds: vm.remainingSeconds)
                .padding(.bottom, 8)

            // Progress bar
            if vm.state != .idle {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(GGColors.border).frame(height: 2)
                        Capsule()
                            .fill(GGColors.accent)
                            .frame(width: geo.size.width * vm.progress, height: 2)
                            .animation(GGAnimations.standard, value: vm.progress)
                    }
                }
                .frame(height: 2)
                .padding(.horizontal, 48)
                .padding(.bottom, 8)
            }

            Spacer()

            // Duration chips (only when idle)
            if vm.state == .idle {
                HStack(spacing: 10) {
                    ForEach(vm.durationOptions, id: \.self) { mins in
                        Button {
                            vm.selectDuration(mins)
                        } label: {
                            Text("\(mins) min")
                                .font(GGFonts.bodyMedium)
                                .foregroundStyle(vm.selectedMinutes == mins ? GGColors.background : GGColors.textSecondary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(vm.selectedMinutes == mins ? GGColors.accent : GGColors.surfaceElevated)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 20)

                // Session label
                TextField("", text: $vm.sessionLabel, prompt: Text("What are you working on?").foregroundColor(GGColors.textTertiary))
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                    .padding(.horizontal, 48)
            }

            // Controls
            controlButtons
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch vm.state {
        case .idle:
            GGPrimaryButton(title: "LOCK IN") { vm.start() }

        case .running:
            HStack(spacing: 12) {
                GGSecondaryButton(title: "PAUSE") { vm.pause() }
                Button {
                    vm.endEarly(run: run, context: context)
                } label: {
                    Text("END")
                        .font(GGFonts.headline)
                        .foregroundStyle(GGColors.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(GGColors.danger.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }

        case .paused:
            HStack(spacing: 12) {
                GGPrimaryButton(title: "RESUME") { vm.resume() }
                Button {
                    vm.endEarly(run: run, context: context)
                } label: {
                    Text("END")
                        .font(GGFonts.headline)
                        .foregroundStyle(GGColors.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(GGColors.danger.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }

        case .complete:
            GGPrimaryButton(title: "NEW SESSION") {
                withAnimation { vm.reset() }
            }
        }
    }

    // MARK: — Completion screen

    private var completionScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(GGColors.accent)

                Text("Session done.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)

                Text("\(vm.selectedMinutes) minutes.")
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
            }

            Spacer()

            VStack(spacing: 12) {
                GGPrimaryButton(title: "ANOTHER") {
                    withAnimation { vm.reset() }
                }
                GGSecondaryButton(title: "DONE") {
                    withAnimation { vm.reset() }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 56)
        }
        .onAppear {
            let session = FocusSession(plannedDurationMinutes: vm.selectedMinutes, sessionLabel: vm.sessionLabel)
            session.actualDurationSeconds = vm.selectedMinutes * 60
            session.wasCompleted = true
            session.endTime = .now
            session.run = run
            context.insert(session)
            if let run {
                let entry = todayEntry(for: run, context: context)
                entry.totalFocusMinutes += vm.selectedMinutes
                try? context.save()
            }
        }
    }
}
