import SwiftUI
import SwiftData

struct NightCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .night)

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

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
        .interactiveDismissDisabled(!vm.isComplete)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case 0: openerStep
        case 1: winsStep
        case 2: lossesStep
        case 3: lessonsStep
        case 4: dopamineStep
        case 5: ratingStep
        default: scoreRevealStep
        }
    }

    // MARK: Step 0
    private var openerStep: some View {
        slideShell {
            VStack(spacing: 12) {
                Text("DAY \(run.dayNumber)")
                    .font(GGFonts.counterMedium)
                    .foregroundStyle(GGColors.textPrimary)
                Text("Done.")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textSecondary)
            }
        } action: {
            GGPrimaryButton(title: "REFLECT", action: vm.advance)
        }
    }

    // MARK: Step 1 — Wins
    private var winsStep: some View {
        slideShell {
            journalField(prompt: "What did you actually win today?", binding: $vm.wins)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
                .opacity(vm.wins.isEmpty ? 0.3 : 1)
                .disabled(vm.wins.isEmpty)
        }
    }

    // MARK: Step 2 — Losses
    private var lossesStep: some View {
        slideShell {
            journalField(prompt: "Where did you slip?", binding: $vm.losses)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    // MARK: Step 3 — Lessons
    private var lessonsStep: some View {
        slideShell {
            journalField(prompt: "What's the one lesson from today?", binding: $vm.lessons)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    // MARK: Step 4 — Dopamine audit
    private var dopamineStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("What did you stay away from?")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)

                Text("Mark what you avoided today.")
                    .font(GGFonts.caption)
                    .foregroundStyle(GGColors.textTertiary)

                VStack(spacing: 0) {
                    ForEach(CheckInViewModel.dopamineItems, id: \.self) { item in
                        let isOn = vm.dopamineAvoided.contains(item)
                        Button {
                            if isOn { vm.dopamineAvoided.remove(item) }
                            else { vm.dopamineAvoided.insert(item) }
                        } label: {
                            HStack {
                                Text(item)
                                    .font(GGFonts.body)
                                    .foregroundStyle(isOn ? GGColors.textPrimary : GGColors.textSecondary)
                                Spacer()
                                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isOn ? GGColors.accent : GGColors.textTertiary)
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        if item != CheckInViewModel.dopamineItems.last {
                            Divider().background(GGColors.border)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(GGColors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    // MARK: Step 5 — Rating
    private var ratingStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("Rate the day.")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textPrimary)

                RatingPicker(value: $vm.dayRating, max: 10)
            }
        } action: {
            GGPrimaryButton(title: "SUBMIT") {
                let entry = todayEntry(for: run, context: context)
                vm.save(to: entry, context: context)
                vm.advance()
            }
        }
    }

    // MARK: Step 6 — Score reveal
    private var scoreRevealStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Text("DISCIPLINE SCORE")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textSecondary)
                    .tightTracking()

                Text("\(vm.computedScore)")
                    .font(GGFonts.counter)
                    .foregroundStyle(scoreColor(vm.computedScore))
                    .contentTransition(.numericText())

                Text(scoreTagline(vm.computedScore))
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
            }

            Spacer()

            GGPrimaryButton(title: "DONE") { dismiss() }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    private func journalField(prompt: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(prompt)
                .font(GGFonts.headline)
                .foregroundStyle(GGColors.textPrimary)

            ZStack(alignment: .topLeading) {
                if binding.wrappedValue.isEmpty {
                    Text("Write it.")
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: binding)
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(minHeight: 120)
            }
            .padding(16)
            .background(GGColors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return GGColors.accent }
        if score >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }

    private func scoreTagline(_ score: Int) -> String {
        if score >= 80 { return "Locked in." }
        if score >= 60 { return "Solid day." }
        if score >= 40 { return "You can do better." }
        return "Tomorrow is the one."
    }
}
