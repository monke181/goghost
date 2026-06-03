import SwiftData
import Foundation

@Model
final class Run {
    var id: UUID
    var name: String
    var why: String
    var focusAreas: [String]
    var goals: [String]
    var completedGoals: [String]
    var streakFreezeCount: Int
    var streakFreezeUsedDates: [Date]
    var startDate: Date
    var targetDays: Int
    var isActive: Bool
    var isCompleted: Bool
    var completedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \DailyEntry.run)
    var entries: [DailyEntry]

    @Relationship(deleteRule: .cascade, inverse: \FocusSession.run)
    var focusSessions: [FocusSession]

    var dayNumber: Int {
        let elapsed = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: .now)).day ?? 0
        return min(elapsed + 1, targetDays)
    }

    var daysRemaining: Int { max(targetDays - dayNumber, 0) }

    var progressFraction: Double { Double(dayNumber) / Double(targetDays) }

    var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let freezeSet = Set(streakFreezeUsedDates.map { cal.startOfDay(for: $0) })
        var streak = 0
        var checkDay = today

        while streak <= 365 {
            let isToday = checkDay == today
            let dayEntry = entries.first(where: { cal.startOfDay(for: $0.date) == checkDay })
            let hasCheckIn = isToday
                ? dayEntry?.morningCheckInCompleted == true
                : dayEntry?.nightCheckInCompleted == true

            if hasCheckIn || freezeSet.contains(checkDay) {
                streak += 1
            } else {
                break
            }

            guard let prev = cal.date(byAdding: .day, value: -1, to: checkDay) else { break }
            checkDay = prev
        }

        return streak
    }

    var last7DayScores: [Int] {
        let today = Calendar.current.startOfDay(for: .now)
        return (0..<7).reversed().map { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { return 0 }
            return entries.first(where: {
                Calendar.current.startOfDay(for: $0.date) == date
            })?.disciplineScore ?? 0
        }
    }

    var averageDisciplineScore: Int {
        let scored = entries.filter { $0.nightCheckInCompleted }
        guard !scored.isEmpty else { return 0 }
        return scored.reduce(0) { $0 + $1.disciplineScore } / scored.count
    }

    init(name: String, why: String, focusAreas: [String], goals: [String] = [], startDate: Date = .now) {
        self.id = UUID()
        self.name = name
        self.why = why
        self.focusAreas = focusAreas
        self.goals = goals
        self.completedGoals = []
        self.streakFreezeCount = 1
        self.streakFreezeUsedDates = []
        self.startDate = startDate
        self.targetDays = 90
        self.isActive = true
        self.isCompleted = false
        self.entries = []
        self.focusSessions = []
    }
}
