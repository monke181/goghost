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
                completionScreen.transition(.opacity)
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

    private var mainScreen: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            Text("GHOST MODE")
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
                .padding(.horizontal, 24)
                .padding(.top, 64)

            Spacer()

            // Timer
            VStack(alignment: .leading, spacing: 4) {
                GGTimerDisplay(remainingSeconds: vm.remainingSeconds)
                    .padding(.horizontal, 24)

                // Progress bar
                if vm.state != .idle {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(GGColors.border).frame(height: 1)
                            Rectangle()
                                .fill(GGColors.accent)
                                .frame(width: geo.size.width * vm.progress, height: 1)
                                .animation(GGAnimations.standard, value: vm.progress)
                        }
                    }
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                // Duration chips (idle only)
                if vm.state == .idle {
                    HStack(spacing: 0) {
                        ForEach(vm.durationOptions, id: \.self) { mins in
                            Button {
                                vm.selectDuration(mins)
                            } label: {
                                Text("\(mins)M")
                                    .font(GGFonts.label)
                                    .tightTracking()
                                    .foregroundStyle(vm.selectedMinutes == mins ? GGColors.background : GGColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(vm.selectedMinutes == mins ? GGColors.textPrimary : .clear)
                                    .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    TextField("", text: $vm.sessionLabel, prompt: Text("WHAT ARE YOU WORKING ON?").foregroundColor(GGColors.textTertiary))
                        .font(GGFonts.label)
                        .tightTracking()
                        .foregroundStyle(GGColors.textPrimary)
                        .padding(14)
                        .background(GGColors.surface)
                        .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                        .padding(.horizontal, 24)
                }

                // Controls
                controlButtons.padding(.horizontal, 24)
            }
            .padding(.bottom, 48)
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch vm.state {
        case .idle:
            GGPrimaryButton(title: "LOCK IN") { vm.start() }

        case .running:
            HStack(spacing: 8) {
                GGSecondaryButton(title: "PAUSE") { vm.pause() }
                Button {
                    vm.endEarly(run: run, context: context)
                } label: {
                    Text("END")
                        .font(GGFonts.label)
                        .tightTracking()
                        .foregroundStyle(GGColors.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .overlay(Rectangle().stroke(GGColors.danger, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

        case .paused:
            HStack(spacing: 8) {
                GGPrimaryButton(title: "RESUME") { vm.resume() }
                Button {
                    vm.endEarly(run: run, context: context)
                } label: {
                    Text("END")
                        .font(GGFonts.label)
                        .tightTracking()
                        .foregroundStyle(GGColors.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .overlay(Rectangle().stroke(GGColors.danger, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

        case .complete:
            GGPrimaryButton(title: "NEW SESSION") {
                withAnimation { vm.reset() }
            }
        }
    }

    private var completionScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("DONE.")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.accent)

                Text("\(vm.selectedMinutes) MINUTES.")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textSecondary)
                    .tightTracking()

                if !vm.sessionLabel.isEmpty {
                    Text(vm.sessionLabel.uppercased())
                        .font(GGFonts.caption)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 8) {
                GGPrimaryButton(title: "ANOTHER") { withAnimation { vm.reset() } }
                GGSecondaryButton(title: "DONE") { withAnimation { vm.reset() } }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
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
