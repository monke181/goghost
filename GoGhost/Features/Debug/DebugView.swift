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
        // Isolated screenshot previews
        case dashboardIsolated
        case morningCheckIn
        case ghostModeIsolated
        case logIsolated
        case nightCheckIn
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
    @State private var seededRun: Run?

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

                    // MARK: Screenshot Data

                    section("SCREENSHOT DATA")

                    infoRow("Each preview seeds fresh mock data and opens full-screen. No tab bar, no chrome. Swipe down or complete flow to exit.")

                    row("→ Dashboard") {
                        seedScreenshotData()
                        preview = Preview(kind: .dashboardIsolated)
                    }
                    row("→ Morning Check-In") {
                        seedScreenshotData()
                        preview = Preview(kind: .morningCheckIn)
                    }
                    row("→ Ghost Mode") {
                        preview = Preview(kind: .ghostModeIsolated)
                    }
                    row("→ Log") {
                        seedScreenshotData()
                        preview = Preview(kind: .logIsolated)
                    }
                    row("→ Night Check-In") {
                        seedScreenshotData()
                        preview = Preview(kind: .nightCheckIn)
                    }
                    row("→ Weekly Recap") {
                        preview = Preview(kind: .weekRecap)
                    }
                    row("→ Run Complete") {
                        seedScreenshotData()
                        preview = Preview(kind: .runComplete)
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
                if let r = seededRun ?? run {
                    RunCompleteView(run: r) { preview = nil }
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

            case .dashboardIsolated:
                DashboardView()

            case .ghostModeIsolated:
                GhostModeView()

            case .logIsolated:
                LogView()

            case .morningCheckIn:
                if let r = seededRun ?? run {
                    MorningCheckInView(run: r)
                }

            case .nightCheckIn:
                if let r = seededRun ?? run {
                    NightCheckInView(run: r)
                }
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

    // MARK: - Screenshot data seeder

    private func seedScreenshotData() {
        for r in runs { context.delete(r) }
        try? context.save()

        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        // 46 days elapsed → dayNumber == 47
        let startDate = cal.date(byAdding: .day, value: -46, to: today)!

        let run = Run(
            name: "90-DAY RUN",
            why: "I'm tired of knowing what I'm capable of and not doing it. This is the year I stop planning and start executing.",
            focusAreas: ["FITNESS", "DEEP WORK", "DISCIPLINE"],
            goals: ["No social media before noon", "Gym 5x per week", "Ship the app"],
            startDate: startDate
        )
        run.completedGoals = ["No social media before noon"]
        run.streakFreezeCount = 2
        context.insert(run)

        let goalSlots: [[String]] = [
            ["Finish the backend feature", "Hit the gym — no excuses", "Read 30 pages"],
            ["90-min deep work before noon", "Cold shower at 6am", "No social media until 5pm"],
            ["Ship the auth flow", "Meal prep for the week", "Journal for 15 minutes"],
            ["Fix the login bug", "Walk 10k steps", "Call back the team"],
            ["Write the spec doc", "Morning run — 5K", "No YouTube today"],
            ["Review and close tickets", "Strength training — don't skip", "Finish the chapter"],
            ["Refactor the data layer", "Stretch + mobility work", "Meditate 10 minutes"],
            ["Prep the demo", "Box jumps and deadlifts", "Review my goals"],
        ]
        let focusAreaPool  = ["DEEP WORK", "FITNESS", "DISCIPLINE", "LEARNING", "HEALTH"]
        let motivationPool = [7, 8, 9, 7, 8, 9, 8, 7, 9, 8]

        let winsPool = [
            "Crushed the morning gym session — hit a new PR on deadlifts",
            "Shipped the feature. Team was impressed. Momentum is building.",
            "Read 40 pages. Didn't check my phone until noon.",
            "90-min deep work block, fully uninterrupted. This is what locked in feels like.",
            "Cold shower every morning this week. The discipline is compounding.",
            "Woke up before the alarm for the first time in weeks.",
            "Stayed off social media the entire day — didn't even miss it.",
            "Prepped meals Sunday, saved 3 hours this week.",
            "Made the hard call in the meeting. Said what needed to be said.",
            "Finished the chapter I'd been putting off. Finally.",
            "6am gym session done before most people are awake.",
            "Wrote 800 words of the spec. Thinking clearly."
        ]
        let lossesPool = [
            "Got sucked into YouTube for 45 minutes mid-afternoon",
            "Checked Twitter before bed — should have logged off at 9",
            "Procrastinated on the hard task until 4pm",
            "Missed the second half of my workout — cut it short",
            "Late-night snacking — broke the clean streak",
            "Scrolled Instagram after lunch for longer than I should have",
            "Skipped the journal — told myself I'd do it later",
            "Got pulled into a two-hour meeting that could have been an email",
            "Doomscrolled 20 min before I caught myself",
            "Ate out instead of cooking — convenience won"
        ]
        let distractionsPool = [
            "Phone notifications all afternoon",
            "YouTube rabbit hole after lunch",
            "Instagram between tasks",
            "Group chat getting noisy",
            "News sites in the background",
            "Reddit during a break that went too long",
            "Slack pings derailing deep work",
            "TV noise from the other room"
        ]
        let lessonsPool = [
            "Block apps before opening the browser — don't rely on willpower",
            "Start with the hardest task before anything else",
            "Sleep is a discipline — treat the cutoff like a commitment",
            "Preparation beats willpower every time",
            "The gap between who I am and who I want to be closes one day at a time",
            "Don't negotiate with distractions — just remove them",
            "Tomorrow's execution starts with tonight's prep",
            "When motivation dips, the system holds",
            "1% better every day compounds into something unrecognizable",
            "\"I don't feel like it\" is not a reason — it's just noise"
        ]
        let journalPool = [
            "Today I dialed in. Deep work locked before 10am, didn't surface until noon. That's the kind of focus I'm building this run around. The streak is real and it's changing how I show up.",
            "Struggled to start this morning — didn't want to move. Did it anyway. Discipline isn't a feeling, it's a decision. Made it again today.",
            "Looking back at day 1 — I'm not the same person. Not dramatically, just quietly. The reps stack. I can feel the compound effect.",
            "Had a close call today — almost scrolled instead of working. Caught it. Closed the app. That moment of choosing differently is exactly what this run is training.",
            "Something shifted this week. The work feels lighter. Not because it's easier, but because I've stopped arguing with myself about whether to do it.",
            "Momentum is a real thing. The first few weeks were a fight. Now the streak continues on its own gravity. It's becoming who I am.",
            "Got distracted in the afternoon. Disappointed, but I came back and closed strong. A full day still counts. Don't let one slip become two.",
            "The why is staying clear. I want to look back at this period knowing I gave it everything. No half-measures, no excuses.",
            "Gym at 6, deep work by 8, no phone until noon. Simple formula. Simple doesn't mean easy — but it means replicable.",
            "Days like today remind me why I started. Clear head, clean execution, no noise. This is the standard I'm raising for myself."
        ]
        let improvedOnPool = [
            "Stayed off my phone after 9pm",
            "Got to bed 45 minutes earlier",
            "Drank water before coffee",
            "No doom-scrolling at lunch — actually rested",
            "Prepped tomorrow's priorities before closing the laptop",
            "Set my three non-negotiables before opening any apps",
            "Stopped at one coffee — skipped the afternoon one",
            "Closed my laptop at a decent hour"
        ]
        let tomorrowPool = [
            "90-min deep work block before any meetings",
            "Gym by 6:30am — no snooze, no negotiation",
            "Ship the dashboard feature — it's been on the list too long",
            "Read 20 pages before noon",
            "Cold shower first — sets the whole day's tone",
            "Phone off until 10am",
            "Write the spec before touching the code",
            "Get to bed by 10pm — sleep is part of the protocol"
        ]

        // Days 3, 7, 11, 16, 20 missed the night check-in (realistic early imperfection)
        let missedNights: Set<Int> = [3, 7, 11, 16, 20]
        // Deterministic score/focus arrays (index % 8)
        let streakNightRatings = [8, 8, 9, 8, 7, 9, 8, 7]
        let earlyNightRatings  = [6, 7, 6, 7, 8, 5, 7, 6]
        let streakFocusMin     = [90, 75, 105, 90, 60, 120, 75, 90]
        let earlyFocusMin      = [45, 30, 60, 45, 20, 75, 45, 30]

        for dayIndex in 0..<46 {
            let dayNum = dayIndex + 1
            let date   = cal.date(byAdding: .day, value: dayIndex, to: startDate)!
            let isMissed = missedNights.contains(dayNum)
            let isStreak = dayNum > 20   // days 21-46 are the locked-in streak

            let entry = DailyEntry(date: date, dayNumber: dayNum)
            entry.run = run

            let goals = goalSlots[dayIndex % goalSlots.count]
            entry.morningCheckInCompleted = true
            entry.morningGoal1 = goals[0]
            entry.morningGoal2 = goals[1]
            entry.morningGoal3 = goals[2]
            entry.morningFocusArea = focusAreaPool[dayIndex % focusAreaPool.count]
            entry.morningMotivationLevel = motivationPool[dayIndex % motivationPool.count]

            entry.nightCheckInCompleted = !isMissed
            if !isMissed {
                entry.nightWins           = winsPool[dayIndex % winsPool.count]
                entry.nightLosses         = lossesPool[dayIndex % lossesPool.count]
                entry.nightDistractedBy   = distractionsPool[dayIndex % distractionsPool.count]
                entry.nightLessons        = lessonsPool[dayIndex % lessonsPool.count]
                entry.nightTomorrowMustDo = tomorrowPool[dayIndex % tomorrowPool.count]
                entry.nightJournal        = journalPool[dayIndex % journalPool.count]
                entry.nightImprovedOn     = improvedOnPool[dayIndex % improvedOnPool.count]
                entry.nightScoreRating    = isStreak ? streakNightRatings[dayIndex % 8] : earlyNightRatings[dayIndex % 8]
                entry.morningGoal1Done    = true
                entry.morningGoal2Done    = isStreak || dayNum > 10
                entry.morningGoal3Done    = isStreak
                entry.dopamineAvoided     = dayNum > 30 ? ["SOCIAL MEDIA"] : []
                entry.totalFocusMinutes   = isStreak ? streakFocusMin[dayIndex % 8] : earlyFocusMin[dayIndex % 8]
            } else {
                entry.totalFocusMinutes = 10
            }

            context.insert(entry)
        }

        // Today: morning done, tonight pending
        let todayEntry = DailyEntry(date: today, dayNumber: 47)
        todayEntry.run = run
        todayEntry.morningCheckInCompleted = true
        todayEntry.morningGoal1 = "Ship the redesign feature"
        todayEntry.morningGoal2 = "45-min morning run"
        todayEntry.morningGoal3 = "No Reddit until evening"
        todayEntry.morningFocusArea = "DEEP WORK"
        todayEntry.morningMotivationLevel = 8
        todayEntry.totalFocusMinutes = 45
        context.insert(todayEntry)

        // Streak: days 21-46 nights (26 days) + today morning = 27
        run.allTimeBestStreak = 27

        try? context.save()
        WidgetDataStore.write(from: run)
        seededRun = run
    }
}
#endif
