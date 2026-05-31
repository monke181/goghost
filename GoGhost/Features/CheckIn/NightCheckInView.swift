import SwiftUI
import SwiftData

struct NightCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .night)

    private var todayEntry: DailyEntry? {
        let today = Calendar.current.startOfDay(for: .now)
        return run.entries.first(where: { Calendar.current.startOfDay(for: $0.date) == today })
    }

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
        .interactiveDismissDisabled(true)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case 0:  openerStep
        case 1:  checklistStep
        case 2:  winsStep
        case 3:  lossesStep
        case 4:  distractionsStep
        case 5:  lessonsStep
        case 6:  tomorrowStep
        case 7:  journalStep
        case 8:  improvedOnStep
        case 9:  dopamineStep
        case 10: ratingStep
        default: scoreRevealStep
        }
    }

    // MARK: - Steps

    private var openerStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 8) {
                Text("DAY \(run.dayNumber)")
                    .font(GGFonts.display)
                    .foregroundStyle(GGColors.textPrimary)
                Text("DONE.")
                    .font(GGFonts.headline)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()
            }
        } action: {
            GGPrimaryButton(title: "REFLECT", action: vm.advance)
        }
    }

    private var checklistStep: some View {
        let entry = todayEntry
        let goals = [entry?.morningGoal1, entry?.morningGoal2, entry?.morningGoal3]
            .compactMap { $0 }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        return slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("TODAY'S\nCHECKLIST")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                if goals.isEmpty {
                    Text("No morning goals set.")
                        .font(GGFonts.body)
                        .foregroundStyle(GGColors.textTertiary)
                } else {
                    VStack(spacing: 0) {
                        ForEach(goals.indices, id: \.self) { i in
                            let isDone = i == 0 ? vm.goal1Done : i == 1 ? vm.goal2Done : vm.goal3Done
                            Button {
                                switch i {
                                case 0: vm.goal1Done.toggle()
                                case 1: vm.goal2Done.toggle()
                                default: vm.goal3Done.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(goals[i].uppercased())
                                        .font(GGFonts.bodyMed)
                                        .foregroundStyle(isDone ? GGColors.textTertiary : GGColors.textPrimary)
                                        .strikethrough(isDone, color: GGColors.textTertiary)
                                        .tightTracking()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Rectangle()
                                        .fill(isDone ? GGColors.accent : .clear)
                                        .frame(width: 8, height: 8)
                                        .overlay(Rectangle().stroke(isDone ? GGColors.accent : GGColors.border, lineWidth: 1))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)

                            if i < goals.count - 1 {
                                Rectangle().fill(GGColors.border).frame(height: 1)
                            }
                        }
                    }
                    .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
                }
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var winsStep: some View {
        slideShell {
            journalField(prompt: "WHAT DID YOU\nDO TODAY?", binding: $vm.wins)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
                .opacity(vm.wins.isEmpty ? 0.3 : 1)
                .disabled(vm.wins.isEmpty)
        }
    }

    private var lossesStep: some View {
        slideShell {
            journalField(prompt: "WHAT DIDN'T\nYOU DO?", binding: $vm.losses)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var distractionsStep: some View {
        slideShell {
            journalField(prompt: "DISTRACTIONS.", binding: $vm.distractions)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var lessonsStep: some View {
        slideShell {
            journalField(prompt: "LESSONS\nLEARNED.", binding: $vm.lessons)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var tomorrowStep: some View {
        slideShell {
            journalField(prompt: "TOMORROW\nMUST DO.", binding: $vm.tomorrowMustDo)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var journalStep: some View {
        slideShell {
            journalField(prompt: "JOURNAL.", binding: $vm.journal)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var improvedOnStep: some View {
        slideShell {
            journalField(prompt: "WHAT I\nIMPROVED ON.", binding: $vm.improvedOn)
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var dopamineStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 16) {
                Text("WHAT DID YOU\nSTAY AWAY FROM?")
                    .font(GGFonts.title)
                    .foregroundStyle(GGColors.textPrimary)
                    .lineSpacing(2)

                VStack(spacing: 0) {
                    ForEach(CheckInViewModel.dopamineItems, id: \.self) { item in
                        let isOn = vm.dopamineAvoided.contains(item)
                        Button {
                            if isOn { vm.dopamineAvoided.remove(item) }
                            else { vm.dopamineAvoided.insert(item) }
                        } label: {
                            HStack {
                                Text(item.uppercased())
                                    .font(GGFonts.bodyMed)
                                    .foregroundStyle(isOn ? GGColors.textPrimary : GGColors.textSecondary)
                                    .tightTracking()
                                Spacer()
                                Rectangle()
                                    .fill(isOn ? GGColors.accent : .clear)
                                    .frame(width: 8, height: 8)
                                    .overlay(Rectangle().stroke(isOn ? GGColors.accent : GGColors.border, lineWidth: 1))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)

                        if item != CheckInViewModel.dopamineItems.last {
                            Rectangle().fill(GGColors.border).frame(height: 1)
                        }
                    }
                }
                .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
            }
        } action: {
            GGPrimaryButton(title: "NEXT", action: vm.advance)
        }
    }

    private var ratingStep: some View {
        slideShell {
            VStack(alignment: .leading, spacing: 20) {
                Text("RATE THE DAY.")
                    .font(GGFonts.title)
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

    private var scoreRevealStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("DISCIPLINE SCORE")
                    .font(GGFonts.label)
                    .foregroundStyle(GGColors.textTertiary)
                    .tightTracking()

                Text("\(vm.computedScore)")
                    .font(GGFonts.hero)
                    .foregroundStyle(scoreColor(vm.computedScore))
                    .contentTransition(.numericText())

                Rectangle().fill(GGColors.border).frame(height: 1)

                Text(scoreTagline(vm.computedScore))
                    .font(GGFonts.body)
                    .foregroundStyle(GGColors.textSecondary)
            }
            .padding(.horizontal, 32)

            Spacer()

            GGPrimaryButton(title: "DONE") { dismiss() }
                .padding(.horizontal, 32)
                .padding(.bottom, 56)
        }
    }

    // MARK: - Helpers

    private func journalField(prompt: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(prompt)
                .font(GGFonts.title)
                .foregroundStyle(GGColors.textPrimary)
                .lineSpacing(2)

            ZStack(alignment: .topLeading) {
                if binding.wrappedValue.isEmpty {
                    Text("—")
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
            .padding(14)
            .background(GGColors.surface)
            .overlay(Rectangle().stroke(GGColors.border, lineWidth: 1))
        }
    }

    private func slideShell<C: View, A: View>(
        @ViewBuilder content: () -> C,
        @ViewBuilder action: () -> A
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GGColors.textTertiary)
                        .padding(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

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

    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }

    private func scoreTagline(_ s: Int) -> String {
        if s >= 80 { return "Locked in." }
        if s >= 60 { return "Solid day." }
        if s >= 40 { return "You can do better." }
        return "Tomorrow is the one."
    }
}
