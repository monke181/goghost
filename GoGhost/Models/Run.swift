import SwiftData
import Foundation

@Model
final class Run {
    var id: UUID
    var name: String
    var why: String
    var focusAreas: [String]
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
        let sorted = entries.sorted { $0.date > $1.date }
        var streak = 0
        var expected = Calendar.current.startOfDay(for: .now)

        for entry in sorted {
            let entryDay = Calendar.current.startOfDay(for: entry.date)
            let isToday = entryDay == expected

            if entryDay == expected {
                let counts = isToday ? entry.morningCheckInCompleted : entry.nightCheckInCompleted
                if counts {
                    streak += 1
                    expected = Calendar.current.date(byAdding: .day, value: -1, to: expected)!
                } else {
                    break
                }
            } else if entryDay < expected {
                break
            }
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

    init(name: String, why: String, focusAreas: [String], startDate: Date = .now) {
        self.id = UUID()
        self.name = name
        self.why = why
        self.focusAreas = focusAreas
        self.startDate = startDate
        self.targetDays = 90
        self.isActive = true
        self.isCompleted = false
        self.entries = []
        self.focusSessions = []
    }
}
