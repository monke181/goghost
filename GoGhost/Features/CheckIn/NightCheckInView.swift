import SwiftUI
import SwiftData

struct NightCheckInView: View {
    let run: Run
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CheckInViewModel(mode: .night)
    @State private var freezeJustUsed = false
    @State private var isNewBestScore = false
    @State private var isSunday: Bool = Calendar.current.component(.weekday, from: .now) == 1

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
                let previousBestScore = run.allTimeBestScore
                let previousBestStreak = run.allTimeBestStreak
                let entry = GoGhost.todayEntry(for: run, context: context)
                vm.save(to: entry, context: context)
                isNewBestScore = vm.computedScore > previousBestScore
                autoApplyFreeze()
                grantFreezeForMilestone()
                if run.currentStreak > previousBestStreak {
                    run.allTimeBestStreak = run.currentStreak
                    try? context.save()
                }
                WidgetDataStore.write(from: run)
                vm.advance()
            }
        }
    }

    private var scoreRevealStep: some View {
        ScoreRevealView(
            score: vm.computedScore,
            streak: run.currentStreak,
            freezeJustUsed: freezeJustUsed,
            isNewBestScore: isNewBestScore,
            weekAvg: isSunday ? run.last7DayAvgScore : nil,
            weekNumber: isSunday ? run.weekNumber : nil,
            onDone: { dismiss() }
        )
    }

    private func autoApplyFreeze() {
        guard run.streakFreezeCount > 0 else { return }
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: today)!

        let yesterdayCheckedIn = run.entries.contains(where: {
            cal.startOfDay(for: $0.date) == yesterday && $0.nightCheckInCompleted
        })
        guard !yesterdayCheckedIn else { return }

        let alreadyFrozen = run.streakFreezeUsedDates.contains(where: {
            cal.startOfDay(for: $0) == yesterday
        })
        guard !alreadyFrozen else { return }

        let hadStreakBefore = run.entries.contains(where: {
            cal.startOfDay(for: $0.date) == twoDaysAgo && $0.nightCheckInCompleted
        })
        guard hadStreakBefore else { return }

        run.streakFreezeUsedDates.append(yesterday)
        run.streakFreezeCount -= 1
        freezeJustUsed = true
        try? context.save()
    }

    private func grantFreezeForMilestone() {
        let streak = run.currentStreak
        guard [7, 14, 21, 30, 60].contains(streak) else { return }
        run.streakFreezeCount += 1
        try? context.save()
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

}

struct ScoreRevealView: View {
    let score: Int
    let streak: Int
    let freezeJustUsed: Bool
    let isNewBestScore: Bool
    let weekAvg: Int?
    let weekNumber: Int?
    let onDone: () -> Void

    @State private var displayScore = 0
    @State private var showMeta = false
    @State private var showButton = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Text("DISCIPLINE SCORE")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                    if isNewBestScore {
                        Text("NEW BEST")
                            .font(GGFonts.label)
                            .foregroundStyle(GGColors.accent)
                            .tightTracking()
                    }
                }

                Text("\(displayScore)")
                    .font(GGFonts.hero)
                    .foregroundStyle(scoreColor(score))
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.linear(duration: 0.04), value: displayScore)

                if showMeta {
                    VStack(alignment: .leading, spacing: 10) {
                        Rectangle().fill(GGColors.border).frame(height: 1)

                        Text(scoreTagline(score))
                            .font(GGFonts.body)
                            .foregroundStyle(GGColors.textSecondary)

                        if streak > 0 {
                            if freezeJustUsed {
                                Text("FREEZE USED — \(streak) DAY STREAK SAVED")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.accent.opacity(0.7))
                                    .tightTracking()
                            } else {
                                Text("\(streak) DAY STREAK")
                                    .font(GGFonts.label)
                                    .foregroundStyle(GGColors.accent)
                                    .tightTracking()
                            }
                        }

                        if let label = milestoneLabel(streak) {
                            Text(label)
                                .font(GGFonts.headline)
                                .foregroundStyle(GGColors.accent)
                        }

                        if let weekAvg, let weekNumber {
                            Rectangle().fill(GGColors.border).frame(height: 1)
                            Text("WEEK \(weekNumber) COMPLETE")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textTertiary)
                                .tightTracking()
                            Text("WEEK AVG: \(weekAvg)")
                                .font(GGFonts.bodyMed)
                                .foregroundStyle(weekAvg >= 70 ? GGColors.accent : GGColors.textPrimary)
                                .tightTracking()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            if showButton {
                GGPrimaryButton(title: buttonLabel(score), action: onDone)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 56)
                    .transition(.opacity)
            } else {
                Color.clear.frame(height: 110)
            }
        }
        .task {
            for i in 1...24 {
                try? await Task.sleep(for: .milliseconds(40))
                displayScore = Int(Double(score) * Double(i) / 24.0)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(1100))
            withAnimation(.easeIn(duration: 0.35)) { showMeta = true }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeIn(duration: 0.25)) { showButton = true }
        }
    }

    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return GGColors.accent }
        if s >= 50 { return GGColors.textPrimary }
        return GGColors.danger
    }

    private func scoreTagline(_ s: Int) -> String {
        if s >= 90 { return "Elite. Stay locked." }
        if s >= 80 { return "Locked in." }
        if s >= 70 { return "Solid run." }
        if s >= 60 { return "Keep the chain." }
        if s >= 50 { return "Still in it." }
        return "Tomorrow is the one."
    }

    private func buttonLabel(_ s: Int) -> String {
        s >= 60 ? "SEE YOU TOMORROW" : "BACK TOMORROW"
    }

    private func milestoneLabel(_ s: Int) -> String? {
        switch s {
        case 7:  return "ONE WEEK STRAIGHT."
        case 14: return "TWO WEEKS LOCKED."
        case 21: return "THREE WEEKS IN."
        case 30: return "30 DAYS. A MONTH STRAIGHT."
        case 60: return "60 DAYS. PAST HALFWAY."
        case 90: return "THE 90-DAY RUN IS COMPLETE."
        default: return nil
        }
    }
}
