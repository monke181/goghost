import SwiftUI
import SwiftData

struct MorningCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .morning)

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            if vm.isComplete {
                completionView
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    stepContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id(vm.step)
                }
            }
        }
        .interactiveDismissDisabled(!vm.isComplete)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case 0: openerStep
        case 1: goalsStep
        case 2: motivationStep
        case 3: focusAreaStep
        default: confirmationStep
        }
    }

    // MARK: Step 0 — Opener
    private var openerStep: some View {
        slideShell {
            VStack(spacing: 12) {
                Text("DAY \(run.dayNumber)")
                    .font(GGFonts.counterMedium)
                    .foregroundStyle(GGColors.textPrimary)

                Text("Morning.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textSecondary)
            }
        } action: {
            GGPrimaryButton(title: "LET'S GO", action: vm.advance)
        }
    }

    // MARK: Step 1 — Goals
    private var goalsStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("What are you getting done today?")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)

                ForEach(Array(zip([1,2,3], [$vm.goal1, $vm.goal2, $vm.goal3])), id: \.0) { num, binding in
                    HStack(spacing: 12) {
                        Text("\(num).")
                            .font(GGFonts.bodyMedium)
                            .foregroundStyle(GGColors.textTertiary)
                            .frame(width: 20)

                        TextField("", text: binding, prompt: Text("Intention \(num)").foregroundColor(GGColors.textTertiary))
                            .font(GGFonts.body)
                            .foregroundStyle(GGColors.textPrimary)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 12)
                            .background(GGColors.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
                .opacity(vm.goal1.isEmpty ? 0.3 : 1)
                .disabled(vm.goal1.isEmpty)
        }
    }

    // MARK: Step 2 — Motivation
    private var motivationStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("How locked in are you right now?")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)

                RatingPicker(value: $vm.motivationLevel, max: 10)
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    // MARK: Step 3 — Focus area
    private var focusAreaStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("Lead with which area today?")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)

                FlowLayout(spacing: 8) {
                    ForEach(run.focusAreas, id: \.self) { area in
                        Button {
                            vm.selectedFocusArea = area
                        } label: {
                            Text(area.uppercased())
                                .font(GGFonts.label)
                                .tightTracking()
                                .foregroundStyle(vm.selectedFocusArea == area ? GGColors.background : GGColors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(vm.selectedFocusArea == area ? GGColors.accent : GGColors.surfaceElevated)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } action: {
            GGPrimaryButton(title: "NEXT") {
                if vm.selectedFocusArea.isEmpty && !run.focusAreas.isEmpty {
                    vm.selectedFocusArea = run.focusAreas[0]
                }
                let entry = todayEntry(for: run, context: context)
                vm.save(to: entry, context: context)
            }
        }
    }

    // MARK: Step 4 — Confirmation
    private var confirmationStep: some View {
        slideShell {
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(GGColors.accent)

                Text("You're locked in.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach([vm.goal1, vm.goal2, vm.goal3].filter { !$0.isEmpty }, id: \.self) { g in
                        HStack(spacing: 8) {
                            Circle().fill(GGColors.accent).frame(width: 4, height: 4)
                            Text(g).font(GGFonts.body).foregroundStyle(GGColors.textSecondary)
                        }
                    }
                }
            }
        } action: {
            GGPrimaryButton(title: "CLOSE", action: { dismiss() })
        }
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(GGColors.accent)
            Text("Locked in.")
                .font(GGFonts.display)
                .foregroundStyle(GGColors.textPrimary)
            Spacer()
            GGPrimaryButton(title: "CLOSE") { dismiss() }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    private func slideShell<Content: View, Action: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
            Spacer()
            action()
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }
}
