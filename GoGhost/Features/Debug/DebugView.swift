#if DEBUG
import SwiftUI
import SwiftData
import UserNotifications
import WidgetKit

// MARK: - Preview item wrapper (unique ID forces fresh fullScreenCover each tap)

private struct Preview: Identifiable {
    let id = UUID()
    let kind: Kind

    enum Kind {
        case scoreReveal(score: Int, streak: Int, freezeUsed: Bool, newBest: Bool, showWeekRecap: Bool)
        case weekRecap
        case runComplete
        case paywall
    }

    static func scoreReveal(score: Int, streak: Int = 0, freezeUsed: Bool = false,
                             newBest: Bool = false, showWeekRecap: Bool = false) -> Preview {
        Preview(kind: .scoreReveal(score: score, streak: streak, freezeUsed: freezeUsed,
                                   newBest: newBest, showWeekRecap: showWeekRecap))
    }
}

// MARK: - Main view

struct DebugView: View {
    @Query(filter: #Predicate<Run> { $0.isActive }) private var runs: [Run]
    @Environment(\.modelContext) private var context

    @State private var preview: Preview?

    private var run: Run? { runs.first }

    var body: some View {
        ZStack {
            GGColors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("DEV")
                        .font(GGFonts.display)
                        .foregroundStyle(GGColors.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.top, 64)
                        .padding(.bottom, 4)

                    Text("DEBUG BUILDS ONLY")
                        .font(GGFonts.label)
                        .foregroundStyle(GGColors.textTertiary)
                        .tightTracking()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                    // MARK: Score Reveal

                    section("SCORE REVEAL")

                    row("Score 45 — off day") {
                        preview = .scoreReveal(score: 45)
                    }
                    row("Score 67 — keep the chain, 3-day streak") {
                        preview = .scoreReveal(score: 67, streak: 3)
                    }
                    row("Score 85 — locked in, 5-day streak") {
                        preview = .scoreReveal(score: 85, streak: 5)
                    }
                    row("Score 95 — elite + NEW BEST") {
                        preview = .scoreReveal(score: 95, streak: 8, newBest: true)
                    }
                    row("Score 80 — FREEZE SAVED streak (12 days)") {
                        preview = .scoreReveal(score: 80, streak: 12, freezeUsed: true)
                    }
                    row("Score 88 — 7-day milestone (ONE WEEK STRAIGHT.)") {
                        preview = .scoreReveal(score: 88, streak: 7)
                    }
                    row("Score 90 — 14-day milestone + new best") {
                        preview = .scoreReveal(score: 90, streak: 14, newBest: true)
                    }
                    row("Score 85 — 30-day milestone") {
                        preview = .scoreReveal(score: 85, streak: 30)
                    }
                    row("Score 78 — Sunday recap (shows VIEW THIS WEEK button)") {
                        preview = .scoreReveal(score: 78, streak: 6, showWeekRecap: true)
                    }
                    row("Score 87 — Sunday + 7-day milestone + new best") {
                        preview = .scoreReveal(score: 87, streak: 7, newBest: true, showWeekRecap: true)
                    }

                    section("WEEKLY RECAP")
                    row("Show weekly recap (mock data)") {
                        preview = Preview(kind: .weekRecap)
                    }

                    // MARK: Run Complete

                    section("RUN COMPLETE CEREMONY")

                    row("Show ceremony (uses live run data)") {
                        preview = Preview(kind: .runComplete)
                    }
                    if let run {
                        row("Reset hasSeenCompletionCeremony → show on next dashboard load") {
                            run.hasSeenCompletionCeremony = false
                            try? context.save()
                        }
                    }

                    // MARK: Paywall

                    section("PAYWALL")

                    row("Show paywall") {
                        preview = Preview(kind: .paywall)
                    }

                    // MARK: Streak & Freeze

                    section("STREAK & FREEZE")

                    if let run {
                        infoRow("Current streak: \(run.currentStreak)  |  Freezes: \(run.streakFreezeCount)  |  Best: \(run.allTimeBestStreak)")

                        row("Grant 1 freeze") {
                            run.streakFreezeCount += 1
                            try? context.save()
                        }
                        row("Use 1 freeze") {
                            if run.streakFreezeCount > 0 { run.streakFreezeCount -= 1 }
                            try? context.save()
                        }
                        row("Simulate freeze auto-save (add yesterday as frozen day)") {
                            let cal = Calendar.current
                            let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: .now))!
                            let alreadyFrozen = run.streakFreezeUsedDates.contains(where: {
                                cal.startOfDay(for: $0) == yesterday
                            })
                            if !alreadyFrozen {
                                run.streakFreezeUsedDates.append(yesterday)
                                if run.streakFreezeCount > 0 { run.streakFreezeCount -= 1 }
                                try? context.save()
                            }
                        }
                        row("Clear all freeze records") {
                            run.streakFreezeUsedDates = []
                            run.streakFreezeCount = 1
                            try? context.save()
                        }
                        row("Set allTimeBestStreak = 21") {
                            run.allTimeBestStreak = 21
                            try? context.save()
                        }
                    } else {
                        infoRow("No active run — complete onboarding first.")
                    }

                    // MARK: Fake Data

                    section("FAKE DATA")

                    if let run {
                        infoRow("Run: day \(run.dayNumber) / 90  |  entries: \(run.entries.count)  |  avg: \(run.averageDisciplineScore)  |  level: \(run.ghostLevel.rawValue)")

                        row("Add 7 consecutive fake entries (random scores)") {
                            addFakeEntries(to: run, count: 7)
                        }
                        row("Add 30 consecutive fake entries") {
                            addFakeEntries(to: run, count: 30)
                        }
                        row("Add 7 perfect entries (score 90+)") {
                            addFakeEntries(to: run, count: 7, score: 10)
                        }
                        row("Add 7 bad entries (score < 50)") {
                            addFakeEntries(to: run, count: 7, score: 2)
                        }
                        row("Fill to 90 days (ceremony test)") {
                            addFakeEntries(to: run, count: 90, startFromDay1: true)
                        }
                        row("DELETE all entries (keeps run)", isDestructive: true) {
                            for entry in run.entries { context.delete(entry) }
                            run.allTimeBestStreak = 0
                            run.streakFreezeUsedDates = []
                            run.streakFreezeCount = 1
                            try? context.save()
                            WidgetDataStore.write(from: run)
                        }
                    }

                    // MARK: Onboarding

                    section("ONBOARDING")

                    row("Reset onboarding (wipe app state)", isDestructive: true) {
                        UserDefaults.standard.set(false, forKey: AppStorageKeys.hasCompletedOnboarding)
                        if let run { context.delete(run) }
                        try? context.save()
                    }

                    // MARK: Notifications

                    section("NOTIFICATIONS")

                    infoRow("Fires in 5 seconds — lock your phone or background the app to see it.")

                    row("Fire morning notification (5s)") {
                        scheduleTestNotification(
                            title: "MORNING CHECK-IN",
                            bodies: [
                                "The version of you that skips this is losing ground.",
                                "Lock in before the day locks you out.",
                                "Ghosts don't sleep in.",
                                "Set the tone. Start the day right.",
                                "Every day you skip, someone else gains ground."
                            ]
                        )
                    }
                    row("Fire night notification (5s)") {
                        scheduleTestNotification(
                            title: "NIGHT REFLECTION",
                            bodies: [
                                "The streak doesn't count itself. Reflect.",
                                "Cap the day. What did you do with it?",
                                "Ghosts don't take days off.",
                                "Don't let today slip by unaccounted for.",
                                "Close the loop. Your future self is watching."
                            ]
                        )
                    }
                    row("Fire all 5 morning variants (5s apart)") {
                        let bodies = [
                            "The version of you that skips this is losing ground.",
                            "Lock in before the day locks you out.",
                            "Ghosts don't sleep in.",
                            "Set the tone. Start the day right.",
                            "Every day you skip, someone else gains ground."
                        ]
                        for (i, body) in bodies.enumerated() {
                            scheduleTestNotification(title: "MORNING CHECK-IN", bodies: [body], delay: TimeInterval(5 + i * 6))
                        }
                    }
                    row("Fire all 5 night variants (5s apart)") {
                        let bodies = [
                            "The streak doesn't count itself. Reflect.",
                            "Cap the day. What did you do with it?",
                            "Ghosts don't take days off.",
                            "Don't let today slip by unaccounted for.",
                            "Close the loop. Your future self is watching."
                        ]
                        for (i, body) in bodies.enumerated() {
                            scheduleTestNotification(title: "NIGHT REFLECTION", bodies: [body], delay: TimeInterval(5 + i * 6))
                        }
                    }
                    row("Cancel all pending test notifications") {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }

                    // MARK: Widgets

                    section("WIDGETS")

                    infoRow("Push mock data to widget shared store. Add your widget to the home/lock screen first, then use these presets to see how each state looks.")

                    row("Widget: 7-day streak, both done, score 87") {
                        writeWidgetMock(streak: 7, day: 23, daysLeft: 67, morning: true, night: true,
                                        score: 87, avg: 81, bestStreak: 7, level: "GHOST",
                                        freezes: 2, momentumUp: true,
                                        last7: [75, 80, 60, 85, 90, 78, 87])
                    }
                    row("Widget: 0 streak, nothing done today") {
                        writeWidgetMock(streak: 0, day: 8, daysLeft: 82, morning: false, night: false,
                                        score: 0, avg: 58, bestStreak: 5, level: "GRINDER",
                                        freezes: 1, momentumUp: false,
                                        last7: [70, 60, 55, 0, 0, 0, 0])
                    }
                    row("Widget: 30-day streak, morning done, no night") {
                        writeWidgetMock(streak: 30, day: 30, daysLeft: 60, morning: true, night: false,
                                        score: 0, avg: 78, bestStreak: 30, level: "PHANTOM",
                                        freezes: 2, momentumUp: true,
                                        last7: [80, 85, 75, 90, 82, 88, 0])
                    }
                    row("Widget: elite run, day 85, 60-streak") {
                        writeWidgetMock(streak: 60, day: 85, daysLeft: 5, morning: true, night: true,
                                        score: 96, avg: 91, bestStreak: 60, level: "ELITE",
                                        freezes: 3, momentumUp: true,
                                        last7: [90, 95, 88, 92, 97, 91, 96])
                    }
                    if let run {
                        row("Widget: write live run data now") {
                            WidgetDataStore.write(from: run)
                        }
                    }

                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $preview) { p in
            switch p.kind {
            case let .scoreReveal(score, streak, freezeUsed, newBest, showWeekRecap):
                ZStack {
                    GGColors.background.ignoresSafeArea()
                    ScoreRevealView(
                        score: score,
                        streak: streak,
                        freezeJustUsed: freezeUsed,
                        isNewBestScore: newBest,
                        weekSummary: showWeekRecap ? mockWeekSummary() : nil,
                        onDone: { preview = nil }
                    )
                }

            case .weekRecap:
                WeeklyRecapView(summary: mockWeekSummary()) { preview = nil }

            case .runComplete:
                if let run {
                    RunCompleteView(run: run) { preview = nil }
                } else {
                    ZStack {
                        GGColors.background.ignoresSafeArea()
                        VStack {
                            Text("NO ACTIVE RUN")
                                .font(GGFonts.label)
                                .foregroundStyle(GGColors.textTertiary)
                                .tightTracking()
                            GGPrimaryButton(title: "CLOSE") { preview = nil }
                                .padding(32)
                        }
                    }
                }

            case .paywall:
                PaywallView()
            }
        }
    }

    // MARK: - Helpers

    private func section(_ title: String) -> some View {
        VStack(spacing: 0) {
            Rectangle().fill(GGColors.border).frame(height: 1)
            Text(title)
                .font(GGFonts.label)
                .foregroundStyle(GGColors.textTertiary)
                .tightTracking()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
            Rectangle().fill(GGColors.border).frame(height: 1)
        }
    }

    private func infoRow(_ text: String) -> some View {
        Text(text)
            .font(GGFonts.caption)
            .foregroundStyle(GGColors.textTertiary)
            .tightTracking()
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
    }

    private func row(_ label: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(GGFonts.body)
                    .foregroundStyle(isDestructive ? GGColors.danger : GGColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(GGColors.textTertiary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Rectangle().fill(GGColors.border).frame(height: 1).padding(.horizontal, 24)
        }
    }

    // MARK: - Mock week summary

    private func mockWeekSummary() -> WeekSummary {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let names = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let scores = [85, 72, 0, 90, 65, 88, 78]
        let focus  = [60, 45, 0, 90, 30, 75, 50]
        let cells = (0..<7).map { i in
            let date = cal.date(byAdding: .day, value: -(6 - i), to: today)!
            return WeekSummary.DayCell(weekday: names[i], date: date, score: scores[i], focusMinutes: focus[i])
        }
        let scored = scores.filter { $0 > 0 }
        return WeekSummary(
            weekNumber: 3,
            startDate: cal.date(byAdding: .day, value: -6, to: today)!,
            endDate: today,
            dayCells: cells,
            avgScore: scored.reduce(0, +) / scored.count,
            bestScore: scored.max()!,
            totalFocusMinutes: focus.reduce(0, +),
            completedDays: scored.count
        )
    }

    // MARK: - Notification tester

    private func scheduleTestNotification(title: String, bodies: [String], delay: TimeInterval = 5) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = bodies.randomElement() ?? bodies[0]
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            let id = "debug-\(UUID().uuidString)"
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }

    // MARK: - Widget mock writer

    private func writeWidgetMock(streak: Int, day: Int, daysLeft: Int, morning: Bool, night: Bool,
                                  score: Int, avg: Int, bestStreak: Int, level: String,
                                  freezes: Int, momentumUp: Bool, last7: [Int]) {
        let suiteName = "group.com.hxndrd.goghost"
        let ud = UserDefaults(suiteName: suiteName) ?? .standard
        ud.set(streak,       forKey: "widget.streak")
        ud.set(day,          forKey: "widget.dayNumber")
        ud.set(daysLeft,     forKey: "widget.daysRemaining")
        ud.set(avg,          forKey: "widget.avgScore")
        ud.set(bestStreak,   forKey: "widget.bestStreak")
        ud.set(level,        forKey: "widget.ghostLevel")
        ud.set(freezes,      forKey: "widget.freezeCount")
        ud.set(momentumUp,   forKey: "widget.momentumBuilding")
        ud.set(morning,      forKey: "widget.morningDone")
        ud.set(night,        forKey: "widget.nightDone")
        ud.set(score,        forKey: "widget.todayScore")
        ud.set(last7,        forKey: "widget.last7Scores")
        ud.set("DEBUG RUN",  forKey: "widget.runName")
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Fake entry generator

    private func addFakeEntries(to run: Run, count: Int, score nightRating: Int? = nil, startFromDay1: Bool = false) {
        let cal = Calendar.current
        let runStart = cal.startOfDay(for: run.startDate)

        for i in 0..<count {
            let date: Date
            if startFromDay1 {
                date = cal.date(byAdding: .day, value: i, to: runStart) ?? runStart
            } else {
                let today = cal.startOfDay(for: .now)
                date = cal.date(byAdding: .day, value: -(count - 1 - i), to: today) ?? today
            }

            guard !run.entries.contains(where: { cal.startOfDay(for: $0.date) == date }) else { continue }

            let dayNum = max(1, (cal.dateComponents([.day], from: runStart, to: date).day ?? 0) + 1)
            let entry = DailyEntry(date: date, dayNumber: dayNum)
            entry.run = run
            entry.morningCheckInCompleted = true
            entry.nightCheckInCompleted = true
            let rating = nightRating ?? Int.random(in: 5...10)
            entry.nightScoreRating = rating
            entry.nightWins = "Debug entry — day \(dayNum)"
            entry.totalFocusMinutes = Int.random(in: 0...120)
            context.insert(entry)
        }

        try? context.save()

        // Update allTimeBestStreak
        if run.currentStreak > run.allTimeBestStreak {
            run.allTimeBestStreak = run.currentStreak
            try? context.save()
        }

        WidgetDataStore.write(from: run)
    }
}
#endif
