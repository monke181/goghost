import SwiftUI
import SwiftData

@Observable
final class CheckInViewModel {
    enum Mode { case morning, night }

    let mode: Mode
    var step = 0
    var isComplete = false

    // Morning
    var goal1 = ""
    var goal2 = ""
    var goal3 = ""
    var motivationLevel = 5
    var selectedFocusArea = ""

    // Night
    var wins = ""
    var losses = ""
    var distractions = ""
    var lessons = ""
    var tomorrowMustDo = ""
    var journal = ""
    var improvedOn = ""
    var dayRating = 5
    var dopamineAvoided: Set<String> = []
    var computedScore = 0

    // Goal checklist (checked off during night reflection)
    var goal1Done = false
    var goal2Done = false
    var goal3Done = false

    var totalSteps: Int { mode == .morning ? 5 : 12 }
    var isLastStep: Bool { step == totalSteps - 1 }

    static let dopamineItems = ["Instagram", "TikTok", "Twitter/X", "YouTube", "News", "Alcohol", "Junk food", "Video games"]

    init(mode: Mode) {
        self.mode = mode
    }

    func advance() {
        if step < totalSteps - 1 {
            withAnimation(GGAnimations.standard) { step += 1 }
        }
    }

    func save(to entry: DailyEntry, context: ModelContext) {
        if mode == .morning {
            entry.morningGoal1 = goal1
            entry.morningGoal2 = goal2
            entry.morningGoal3 = goal3
            entry.morningMotivationLevel = motivationLevel
            entry.morningFocusArea = selectedFocusArea
            entry.morningCheckInCompleted = true
        } else {
            entry.nightWins = wins
            entry.nightLosses = losses
            entry.nightDistractedBy = distractions
            entry.nightLessons = lessons
            entry.nightTomorrowMustDo = tomorrowMustDo
            entry.nightJournal = journal
            entry.nightImprovedOn = improvedOn
            entry.nightScoreRating = dayRating
            entry.dopamineAvoided = Array(dopamineAvoided)
            entry.morningGoal1Done = goal1Done
            entry.morningGoal2Done = goal2Done
            entry.morningGoal3Done = goal3Done
            entry.nightCheckInCompleted = true
            computedScore = entry.disciplineScore
        }
        try? context.save()
        withAnimation(GGAnimations.standard) { isComplete = true }
    }
}

// Helper: fetch or create today's entry for a run
func todayEntry(for run: Run, context: ModelContext) -> DailyEntry {
    let today = Calendar.current.startOfDay(for: .now)
    if let existing = run.entries.first(where: {
        Calendar.current.startOfDay(for: $0.date) == today
    }) { return existing }
    let entry = DailyEntry(date: today, dayNumber: run.dayNumber)
    entry.run = run
    context.insert(entry)
    return entry
}
